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
require 'deep_merge' unless {}.respond_to?(:deep_merge!)

module AbstractFeatureBranch
  def self.application_root
    @application_root ||= initialize_application_root
  end
  def self.initialize_application_root
    @application_root = Rails.root
  end
  def self.application_root=(path)
    @application_root = path
  end
  def self.environment_variable_overrides
    @environment_variable_overrides ||= load_environment_variable_overrides
  end
  def self.load_environment_variable_overrides
    @environment_variable_overrides = featureize_keys(select_feature_keys(booleanize_values(downcase_keys(ENV))))
  end
  def self.local_features
    @local_features ||= load_local_features
  end
  def self.load_local_features
    @local_features = {}
    Dir.glob(File.join(application_root, 'config', 'features', '**', '*.local.yml')).each do |feature_configuration_file|
      @local_features.deep_merge!(downcase_feature_hash_keys(YAML.load_file(feature_configuration_file)))
    end
    main_local_features_file = File.join(application_root, 'config', 'features.local.yml')
    @local_features.deep_merge!(downcase_feature_hash_keys(YAML.load_file(main_local_features_file))) if File.exists?(main_local_features_file)
    @local_features
  end
  def self.features
    @features ||= load_features
  end
  def self.load_features
    @features = {}
    Dir.glob(File.join(application_root, 'config', 'features', '**', '*.yml')).each do |feature_configuration_file|
      @features.deep_merge!(downcase_feature_hash_keys(YAML.load_file(feature_configuration_file)))
    end
    main_features_file = File.join(application_root, 'config', 'features.yml')
    @features.deep_merge!(downcase_feature_hash_keys(YAML.load_file(main_features_file))) if File.exists?(main_features_file)
    @features
  end
  # performance optimization via caching of feature values resolved through environment variable overrides and local features
  def self.environment_features(environment)
    @environment_features ||= {}
    @environment_features[environment] ||= load_environment_features(environment)
  end
  def self.load_environment_features(environment)
    features[environment] ||= {}
    local_features[environment] ||= {}
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

  def self.downcase_feature_hash_keys(hash)
    Hash[hash.map {|k, v| [k, v && downcase_keys(v)]}]
  end
end

require File.join(File.dirname(__FILE__), 'ext', 'feature_branch')
