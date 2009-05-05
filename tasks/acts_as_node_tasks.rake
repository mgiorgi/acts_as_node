require 'fileutils'

desc 'Updates application with the necessary javascripts for unobtrusive_javascript.'
task :update_scripts do
  print "Hola"
  FileUtils.cp_r Dir['assets/javascripts/jsviz'], 'public/javascripts'
end

desc 'Removes the javascripts for the plugin.'
task :remove_scripts do
  FileUtils.rm_r '../../../public/javascripts/jsviz', :force => true
end

