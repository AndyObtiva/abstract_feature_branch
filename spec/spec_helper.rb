ENV['APP_ENV'] = 'test'
ENV['CODECLIMATE_REPO_TOKEN'] = '535ff40cf55554362b2f48b85e913a7362f0cf3e51638455dab456006258c5a0'
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
if RUBY_VERSION >= '1.9'
  begin
    require 'coveralls'
    Coveralls.wear!
    require "codeclimate-test-reporter"
    CodeClimate::TestReporter.start
  rescue LoadError, StandardError
    #no op to support Ruby 1.8.7, ree, jruby-18mode, and Rubinius
  end
end
require File.join(File.dirname(__FILE__), '..', 'lib', 'abstract_feature_branch')
AbstractFeatureBranch.logger.level = Logger::WARN
AbstractFeatureBranch.load_application_features
