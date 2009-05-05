require "fileutils"
class ActsAsNodeGenerator < Rails::Generator::Base

  def manifest
    class_path = ''
    
    record do |m|
      
      # Model directory
      m.directory File.join('app/controllers', class_path)
      
      # Model classes
      m.template 'acts_as_node_controller.rb', File.join('app/controllers', class_path, "acts_as_node_controller.rb")
      
      #mkdir of views for the controller
      FileUtils.mkdir 'app/views/acts_as_node'
      
      #Copy of rxml to the generated view
      m.template 'generate_graph.rxml', File.join('app/views/acts_as_node', class_path, "generate_graph.rxml")
    
    end
  end
  
end
