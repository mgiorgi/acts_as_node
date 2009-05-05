require 'acts_as_node'
require 'asset_tag_helper_patches'
ActiveRecord::Base.send :include, ActsAsNode
ActionView::Base.send :include, ActsAsNodeViewHelper