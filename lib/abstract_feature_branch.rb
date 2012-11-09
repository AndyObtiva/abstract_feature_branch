require 'rubygems'
require 'bundler'
Bundler.setup(:default)
require 'rails_config'

RailsConfig.setup do |config|
  config.const_name = "Settings"
end
RailsConfig.load_and_set_settings("#{Rails.root}/config/features.yml")

# Add this line if you need a local override. Make sure it is added to .gitignore
#Settings.add_source!("#{Rails.root}/config/features.local.yml")

Settings.reload!

require File.join(File.dirname(__FILE__), 'ext', 'feature_branch')
