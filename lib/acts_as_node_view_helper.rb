# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
module ActsAsNodeViewHelper
  public
  
  NODE_INSTANTIATION = "
        var isSVG = layout.svg;
        isSVG = false;
	if (isSVG) {
          var nodeElement = null;
          if (dataNode.picture!=null && dataNode.picture.length>0) {
            nodeElement = document.createElementNS(svgNS,'image');
            nodeElement.setAttributeNS(null,'width',12);
            nodeElement.setAttributeNS(null,'height',12);
            nodeElement.setAttributeNS(xlinkNS,'href',dataNode.picture);
          } else {
            nodeElement = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
            nodeElement.setAttribute('stroke', '#888888');
            nodeElement.setAttribute('stroke-width', '.25px');
            nodeElement.setAttribute('fill', dataNode.color);
            nodeElement.setAttribute('r', 6 + 'px');
          }
	  var strTitle = 'TITLE=\"header=[Datos] body=[mas datos]\"';
          nodeElement.setAttribute('TITLE', 'header=[Datos] body=[mas datos]');
	  nodeElement.onmousedown =  new EventHandler( layout, layout.handleMouseDownEvent, modelNode.id )
	  return nodeElement;
	} else {
	  var nodeElement = document.createElement( 'div' );
	  nodeElement.style.position = 'absolute';
	  nodeElement.style.width = '12px';
	  nodeElement.style.height = '12px';
	  var color = dataNode.color.replace( '#', '' );
          if (dataNode.picture!=null && dataNode.picture.length>0) {
            nodeElement.style.backgroundImage = 'url('+dataNode.picture+')';
          } else {
            nodeElement.style.backgroundImage = 'url(http://kylescholz.com/cgi-bin/bubble.pl?title=&r=12&pt=8&b=888888&c=' + color + ')';
          }
          nodeElement.setAttribute(\"TITLE\", \"header=[\"+dataNode.title+\"] body=[\"+dataNode.content+\"] \");
          nodeElement.innerHTML = '<img width=\"1\" height=\"1\">';
          nodeElement.onmousedown =  new EventHandler( layout, layout.handleMouseDownEvent, modelNode.id );
	  return nodeElement;
	}
  "
  
  GRAPH_LAYOUT  = {
    :SnowflakeLayout => lambda{ |values| "function init() {

				var TIMEDBUILD = window.location.href.indexOf('TIMEDBUILD')>0 ? true : false;
     var svgNS = 'http://www.w3.org/2000/svg';
     var xlinkNS = 'http://www.w3.org/1999/xlink';

				/* 1) Create a new SnowflakeLayout.
				 * 
				 * If you're going to place the graph in an HTML Element, other
				 * than the <body>, remember that it must have a known size and
				 * position (via element.offsetWidth, element.offsetHeight,
				 * element.offsetTop, element.offsetLeft).
				 */
				var layout = new SnowflakeLayout( #{values[:container]}, true );
				layout.view.skewBase=575;
				layout.setSize();

				/* 2) Configure the layout.
				 * 
				 * This configuration defines how we handle the addition of
				 * different kinds of nodes to the graph. For each 'type' of
				 * node, we tell the layout how to create a 'model' and 'view'
				 * of the new node.
				 */
				
				layout.config._default = {

				/* The 'model' defines the underlying structure of our graph.
				 * For a SnowflakeModel, we need to define the following for
				 * each node:
				 * 
				 * - childRadius: the edge length to this node's children
				 * - fanAngle: the maximum angle in which child nodes will be
				 *   layed out
				 * - rootAngle: the base angle of the graph at the origin (this
				 *   is automatically determined for all child nodes)
				 * 
				 * These parameters determine how this new node will interact
				 * with other nodes in our graph. The 'model' attribute of a
				 * class in our configuration must return a JavaScript Object
				 * containing these values.
				 */

					model: function( dataNode ) {
						return {
							childRadius: #{values[:childRadius]},
							fanAngle: dataNode.root ? 360: #{values[:fanAngle]},
							rootAngle: 0
						}
					},

				/* The 'view' defines what the nodes in our graph look like.
				 * The 'view' attribute of a class must return a DOM element -- 
				 * JSViz supports most HTML and SVG elements. You can control
				 * the appearence and behavior of view elements just like any
				 * DOM element: 
				 * 
				 * CSS: Point to a CSS style sheet using the 'className'
				 * attribute of the DOM element.
				 * 
				 * Contents: Indicate the node's contents, in HTML, using the
				 * 'appendChild' function or by setting DOM element's innerHTML.
				 * 
				 * Behavior: Add an event handler using the EventHandler factory
				 * class. For example: 
				 * 
				 * nodeElement.onclick = new EventHandler( _caller, _handler, arg0, arg1... );
				 * 
				 * where _caller is an object instance that _handler may refer
				 * to as 'this' (use 'window' if the function is in the global
				 * scope), _handler is the function to be executed, and any
				 * additional arguments are passed as parameters to _handler. 
				 */

					view: function( dataNode, modelNode ) {
                                          #{NODE_INSTANTIATION}
					}
				}
				
				/* 3) Override the default edge properties builder.
				 * 
				 * This is optional of course, but we'll create a custom edge
				 * builder that draws edges in the color of the parent node.
				 * 
				 * @return Object
				 */ 
				layout.viewEdgeBuilder = function( dataNodeSrc, dataNodeDest ) {
					if ( this.svg ) {
						return {
							'stroke': dataNodeSrc.color,
							'stroke-width': '2px',
							'stroke-dasharray': '2,4'
						}
					} else {
						return {
							'pixelColor': dataNodeSrc.color,
							'pixelWidth': '2px',
							'pixelHeight': '2px',
							'pixels': 8
						}
					}
				}

				/* 4) Make an loader to process the contents of our file.
				 * 
				 * Here, we're using the XMLTreeLoader. 
				 */
				var loader = new XMLTreeLoader( layout.dataGraph );
				loader.load( '#{values[:url]}' );

				/* 5a) Control the addition of nodes and edges with a timer.
				 * 
				 * This enables the graph to start organizng as data is loaded.
				 * Use a larger tick time for smoother animation, but slower
				 * build time.
				 */
				if ( TIMEDBUILD ) {
					var buildTimer = new Timer( 0 );
					buildTimer.subscribe( layout );
					buildTimer.start();

				/* 5b) Or ... Add all nodes at once.
				 * 
				 * Use a timer and simple build class to load all nodes when
				 * they are available then stop polling for new nodes.
				 */
				} else {
					var SimpleBuilder = function() {
						this.started = false;
						this.update = function() {
							var d = layout.dequeueNode();
							if ( !this.started && d ) {
								this.started=true;
								while( layout.dequeueNode() ) {};
							}
							if ( this.started && !d ) { return false; }
						}
					}				
					var buildTimer = new Timer(0);
					buildTimer.subscribe( new SimpleBuilder );
					buildTimer.start();
				}
			}
                        Event.observe(window, 'load', init);
    " }, 
    :ForceDirectedLayout => lambda { |values| 
      			"function init() {

				/* 1) Create a new SnowflakeLayout.
				 * 
				 * If you're going to place the graph in an HTML Element, other
				 * the <body>, remember that it must have a known size and
				 * position (via element.offsetWidth, element.offsetHeight,
				 * element.offsetTop, element.offsetLeft).
				 */
				var layout = new ForceDirectedLayout(  #{values[:container]}, true );
				layout.view.skewBase=575;
				layout.setSize();

				/* 2) Configure the layout.
				 * 
				 * This configuration defines how we handle the addition of
				 * different kinds of nodes to the graph. For each 'type' of
				 * node, we tell the layout how to create a 'model' and 'view'
				 * of the new node.
				 */
				layout.config._default = {
					
				/* The 'model' defines the underlying structure of our graph.
				 * For a SnowflakeModel, we need to define the following for
				 * each node:
				 * 
				 * - childRadius: the edge length to this node's children
				 * - fanAngle: the maximum angle in which child nodes will be
				 *   layed out
				 * - rootAngle: the base angle of the graph at the origin (this
				 *   is automatically determined for all child nodes)
				 * 
				 * These parameters determine how this new node will interact
				 * with other nodes in our graph. The 'model' attribute of a
				 * class in our configuration must return a JavaScript Object
				 * containing these values.
				 */
				
					model: function( dataNode ) {
						return {
							mass: #{values[:mass]}
						}
					},
					
				/* The 'view' defines what the nodes in our graph look like.
				 * The 'view' attribute of a class must return a DOM element -- 
				 * JSViz supports most HTML and SVG elements. You can control
				 * the appearence and behavior of view elements just like any
				 * DOM element: 
				 * 
				 * CSS: Point to a CSS style sheet using the 'className'
				 * attribute of the DOM element.
				 * 
				 * Contents: Indicate the node's contents, in HTML, using the
				 * 'appendChild' function or by setting DOM element's innerHTML.
				 * 
				 * Behavior: Add an event handler using the EventHandler factory
				 * class. For example: 
				 * 
				 * nodeElement.onclick = new EventHandler( _caller, _handler, arg0, arg1... );
				 * 
				 * where _caller is an object instance that _handler may refer
				 * to as 'this' (use 'window' if the function is in the global
				 * scope), _handler is the function to be executed, and any
				 * additional arguments are passed as parameters to _handler. 
				 */

					view: function( dataNode, modelNode ) {
                                          #{NODE_INSTANTIATION}
					}
				}

				/* Force Directed Graphs are a simulation of different kinds of
				 * forces between particles. In JSViz, a graph edge is typically
				 * represented as an attractive 'spring' force connecting
				 * two nodes.
				 * 
				 * It's often the case that parent-child relationships are
				 * represented with stricter force rules. This can help a graph
				 * organize with fewer overlapping edges.
				 */
				
        		layout.forces.spring._default = function( nodeA, nodeB, isParentChild ) {
					if (isParentChild) {
						return {
							springConstant: 0.5,
							dampingConstant: 0.2,
							restLength: 20
						}
					} else {
						return {
							springConstant: 0.2,
							dampingConstant: 0.2,
							restLength: 20
						}
					}
				}

     /* Note that these configurations are directed: The above
				 * configuration would apply to an edge from a node of type
				 * 'A' to a node of type 'B', but not from a 'B' to an 'A' ...
				 * use a additional configuration from that. 
				 */
				
				/* The other forces in our graph repel each node from another.
				 * This function should be the same for all node types.
				 */
        		layout.forces.magnet = function() {
					return {
						magnetConstant: -2000,
						minimumDistance: 10
					}
				}
				
				/* You don't need to include the above function in your
				 * application if you are satisfied with the default
				 * implementation.
				 */
				
				/* 3) Override the default edge properties builder.
				 * 
				 * @return DOMElement
				 */ 
				layout.viewEdgeBuilder = function( dataNodeSrc, dataNodeDest ) {
					if ( this.svg ) {
						return {
							'stroke': dataNodeSrc.color,
							'stroke-width': '2px',
							'stroke-dasharray': '2,4'
						}
					} else {
						return {
							'pixelColor': dataNodeSrc.color,
							'pixelWidth': '2px',
							'pixelHeight': '2px',
							'pixels': 5
						}
					}
				}

				/* 4) Make an loader to process the contents of our file.
				 * 
				 * Here, we're using the XML Loader. 
				 */
				var loader = new XMLTreeLoader( layout.dataGraph );
				loader.load( '#{values[:url]}' );

				/* 5) Control the addition of nodes and edges with a timer.
				 * 
				 * This enables the graph to start organizng as data is loaded.
				 * Use a larger tick time for smoother animation, but slower
				 * build time.
				 */
				var buildTimer = new Timer( 150 );
				buildTimer.subscribe( layout );
				buildTimer.start();
			}
                        Event.observe(window, 'load', init);"
    }
  }
  
  def graph_drawing(class_name, root_id, options = {})
    defaults = { :layout => "SnowflakeLayout", :title => 'name', :mass => 0.5, :fanAngle => 300, :childRadius => 40, :container => "document.body", :class_name => class_name.to_s, :root => root_id.to_s }
    options[:children_accessors] = YAML.dump(options[:children_accessors])
    options[:children_fields] = YAML.dump(options[:children_fields])
    opts = defaults.merge(options)
    opts[:url] =  (url_for :controller => :acts_as_node, :action => :generate_graph, :only_path => false, :params => opts).gsub(/amp;/, '&')
    js = GRAPH_LAYOUT[opts[:layout].to_sym].call opts
    javascript_tag js
  end
end
