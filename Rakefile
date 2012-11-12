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
  gem.summary = %Q{abstract_feature_branch is a Rails gem that enables developers to easily branch by
  abstraction as per this pattern: http://paulhammant.com/blog/branch_by_abstraction.html}
  gem.description = <<-TEXT
It gives ability to wrap blocks of code with an abstract feature branch name, and then
specify which features to be switched on or off in a configuration file.

The goal is to build out future features with full integration into the codebase, thus
ensuring no delay in integration in the future, while releasing currently done features
at the same time. Developers then disable future features until they are ready to be
switched on in production, but do enable them in staging and locally.

This gives developers the added benefit of being able to switch a feature off after
release should big problems arise for a high risk feature.
  TEXT
  gem.authors = ["Annas \"Andy\" Maleh"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'

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
