ENV['APP_ENV'] = 'test'
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
if RUBY_VERSION >= "1.9"
  require 'coveralls'
  Coveralls.wear!
end
require File.join(File.dirname(__FILE__), '..', 'lib', 'abstract_feature_branch')
AbstractFeatureBranch.logger.level = Logger::WARN
AbstractFeatureBranch.load_application_features