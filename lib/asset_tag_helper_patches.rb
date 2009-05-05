module ActionView::Helpers::AssetTagHelper
  alias_method :rails_javascript_include_tag, :javascript_include_tag
  
  # Adds a new option to Rails' built-in <tt>javascript_include_tag</tt>
  # helper - <tt>:unobtrusive</tt>. Works in the same way as <tt>:defaults</tt> - specifying 
  # <tt>:unobtrusive</tt> will make sure the necessary javascript
  # libraries and behaviours file +script+ tags are loaded. Will happily
  # work along side <tt>:defaults</tt>.
  #
  #  <%= javascript_include_tag :defaults, :unobtrusive %>
  #
  # This replaces the old +unobtrusive_javascript_files+ helper.
  def javascript_include_tag(*sources)
    behaviours = ''
    if sources.delete :acts_as_node
      #graph drawing
      root_dir = 'jsviz/0.3.3/'
      sources = sources.concat(
        ['physics/ParticleModel', 'physics/Magnet', 'physics/Spring', 'physics/Particle', 'physics/RungeKuttaIntegrator', 'geometry/SnowflakeGraphModel', 'layout/graph/ForceDirectedLayout', 'layout/graph/SnowflakeLayout', 'layout/view/HTMLGraphView', 'layout/view/SVGGraphView', 'util/Timer', 'util/EventHandler', 'io/DataGraph', 'io/JSVIZHTTP', 'io/XMLTreeLoader']
      ).uniq.map { |js_file| root_dir + js_file }
      sources = sources.concat(['tooltip/boxover'])
    end
    rails_javascript_include_tag(*sources)
  end  
end
