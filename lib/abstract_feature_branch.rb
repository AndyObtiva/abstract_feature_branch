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
  def self.environment_variable_overrides
    @environment_variable_overrides ||= load_environment_variable_overrides
  end
  def self.load_environment_variable_overrides
    @environment_variable_overrides = featureize_keys(select_feature_keys(booleanize_values(downcase_keys(ENV))))
  end
  def self.local_features
    @local_features ||= Hash[YAML.load_file(File.join(Rails.root, 'config', 'features.local.yml')).map {|k, v| [k, v && downcase_keys(v)]}]
    @local_features
  end
  def self.features
    @features ||= Hash[YAML.load_file(File.join(Rails.root, 'config', 'features.yml')).map {|k, v| [k, v && downcase_keys(v)]}]
    @features
  end
  # performance optimization via caching of feature values resolved through environment variable overrides and local features
  def self.environment_features(environment)
    @environment_features ||= {}
    @environment_features[environment] ||= load_environment_features(environment)
  end
  def self.load_environment_features(environment)
    @environment_features[environment] = features[environment].merge(local_features[environment]).merge(environment_variable_overrides)
  end

  private

  ENV_FEATURE_PREFIX = "abstract_feature_branch_"

  def self.featureize_keys(hash)
    Hash[hash.map {|k, v| [k.sub(ENV_FEATURE_PREFIX, ''), v]}]
  end

  def self.select_feature_keys(hash)
    hash.reject {|k, v| !k.start_with?(ENV_FEATURE_PREFIX)} # using reject for Ruby 1.8 compatibility as select returns an array in it
  end

  def self.booleanize_values(hash)
    Hash[hash.map {|k, v| [k, v.downcase == 'true']}]
  end

  def self.downcase_keys(hash)
    Hash[hash.map {|k, v| [k.downcase, v]}]
  end
end

require File.join(File.dirname(__FILE__), 'ext', 'feature_branch')
