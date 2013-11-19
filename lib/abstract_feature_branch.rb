require 'rubygems'
require 'bundler'
require 'yaml'
begin
  Bundler.setup(:default)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

module AbstractFeatureBranch
  def self.features
    @features ||= YAML.load_file(File.join(Rails.root, 'config', 'features.yml'))
  end
end

require File.join(File.dirname(__FILE__), 'ext', 'feature_branch')
require File.join(File.dirname(__FILE__), 'generators', 'install_generator')
