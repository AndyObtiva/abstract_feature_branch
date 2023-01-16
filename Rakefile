# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "abstract_feature_branch"
  gem.homepage = "http://github.com/AndyObtiva/abstract_feature_branch"
  gem.license = "MIT"
  gem.summary = %Q{abstract_feature_branch is a Ruby gem that provides a variation on the Branch by Abstraction Pattern by Paul Hammant and the Feature Toggles Pattern by Martin Fowler (aka Feature Flags) to enable Continuous Integration and Trunk-Based Development.}
  gem.description = <<~MULTI_LINE_STRING
abstract_feature_branch is a Ruby gem that provides a unique variation on the Branch by Abstraction Pattern by Paul Hammant and the Feature Toggles Pattern by Martin Fowler to enhance team productivity and improve software fault tolerance.

It provides the ability to wrap blocks of code with an abstract feature branch name, and then specify in a configuration file which features to be switched on or off.

The goal is to build out upcoming features in the same source code repository branch (i.e. Continuous Integration and Trunk-Based Development), regardless of whether all are completed by the next release date or not, thus increasing team productivity by preventing integration delays. Developers then disable in-progress features until they are ready to be switched on in production, yet enable them locally and in staging environments for in-progress testing.

This gives developers the added benefit of being able to switch a feature off after release should big problems arise for a high risk feature.

abstract_feature_branch additionally supports Domain Driven Design's pattern of Bounded Contexts by allowing developers to configure context-specific feature files if needed.

abstract_feature_branch is one of the simplest and most minimalistic "Feature Flags" Ruby gems out there as it enables you to get started very quickly by simply leveraging YAML files without having to set up a data store if you do not need it (albeit, you also have the option to use Redis as a very fast in-memory data store).
  MULTI_LINE_STRING
  gem.authors = ["Andy Maleh"]
  gem.post_install_message = <<~MULTI_LINE_STRING
  
    Rails-only post-install instructions:
    
    1) Run the following command to generate the Rails initializer and basic feature files:
    
    rails g abstract_feature_branch:install
    
    2) Optionally, you may run this command to generate feature files per context:
    
    rails g abstract_feature_branch:context context_path
       
    3) Optionally, install Redis server with [Homebrew](https://brew.sh/) by running:
    
    brew install redis
    
    4) Optionally, install redis client gem (required with Redis server) by adding the following line to Gemfile above abstract_feature_branch:
    
    gem 'redis', '~> 5.0.5'
    
    Afterwards, run:
    
    bundle
    
    5) Optionally, customize configuration in config/initializers/abstract_feature_branch.rb
    
    (can be useful for changing location of feature files in Rails application,
    configuring Redis with a Redis or ConnectionPool instance to use for overrides and per-user feature enablement,
    and/or troubleshooting specific Rails environment feature configurations)
    
  MULTI_LINE_STRING
  gem.files = Dir['README.md', 'LICENSE.txt', 'VERSION', 'CHANGELOG.md', 'abstract_feature_branch.gemspec', 'lib/**/*']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'

# Note: adding last_comment to Rake.application for backwards compatibility reasons,
# needed by rspec due to using a newer version of rake in the newer Ruby
Rake.application.instance_eval do
  def last_comment
  end
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "abstract_feature_branch #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

$LOAD_PATH << 'lib'
load 'lib/generators/templates/lib/tasks/abstract_feature_branch.rake'
