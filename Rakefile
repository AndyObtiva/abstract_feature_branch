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
abstract_feature_branch is a Rails gem that enables developers to easily branch by abstraction as per this pattern:
http://paulhammant.com/blog/branch_by_abstraction.html

It is a productivity and fault tolerance enhancing team practice that has been utilized by professional software development
teams at large corporations, such as Sears and Groupon.

It provides the ability to wrap blocks of code with an abstract feature branch name, and then
specify in a configuration file which features to be switched on or off.

The goal is to build out upcoming features in the same source code repository branch, regardless of whether all are
completed by the next release date or not, thus increasing team productivity by preventing integration delays.
Developers then disable in-progress features until they are ready to be switched on in production, yet enable them
locally and in staging environments for in-progress testing.

This gives developers the added benefit of being able to switch a feature off after release should big problems arise
for a high risk feature.

abstract_feature_branch additionally supports DDD's pattern of
Bounded Contexts by allowing developers to configure
context-specific feature files if needed.
  TEXT
  gem.authors = ["Annas \"Andy\" Maleh"]
  gem.files.exclude 'spec/*'
  gem.files.exclude 'config/*'
  gem.files.exclude 'Gemfile'
  gem.files.exclude 'Gemfile.lock'
  gem.files.exclude 'Rakefile'
  gem.files.exclude '.ruby-gemset'
  gem.files.exclude '.ruby-version'
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
