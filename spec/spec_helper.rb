require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
module Rails
  def self.root
    File.join(File.dirname(__FILE__), '..')
  end
  def self.env
    'test'
  end
end
require File.join(File.dirname(__FILE__), '..', 'lib', 'abstract_feature_branch')
