require 'fileutils'
# I show the README file.
puts IO.read(File.join(File.dirname(__FILE__), 'README'))

# Install hook code here
FileUtils.cp_r Dir[File.join(File.dirname(__FILE__), 'assets/javascripts/jsviz')], RAILS_ROOT + '/public/javascripts'
FileUtils.cp_r Dir[File.join(File.dirname(__FILE__), 'assets/javascripts/tooltip')], RAILS_ROOT + '/public/javascripts'

