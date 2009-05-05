class ActsAsNodeController < ActionController::Base
 def generate_graph(options = {})
   @root = params[:class_name].to_s.constantize.find(params[:root].to_i)
   children_accessors_hash = YAML.load(params[:children_accessors])
   @children_accessors = ({params[:class_name].to_s.to_sym => []}).merge(children_accessors_hash)
   #We use children (for acts_as_tree, etc) as a defualt accessor.
   @children_accessors[params[:class_name].to_s.to_sym] = [:children] if @children_accessors[params[:class_name].to_s.to_sym].length == 0
   @children_fields = YAML.load(params[:children_fields])
   @visited = {}
   @children_accessors.keys.each { |klazz| @visited[klazz] = [] }
   @depth = params[:depth]
 end
end
