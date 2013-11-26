require 'rubygems'
require 'bundler'
require 'yaml'
YAML::ENGINE.yamler = "syck" if RUBY_VERSION.start_with?('1.9')
begin
  Bundler.setup(:default)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'logger' unless defined?(Rails) && Rails.logger
require 'deep_merge' unless {}.respond_to?(:deep_merge!)

module AbstractFeatureBranch
  def self.application_root
    @application_root = @application_root || initialize_application_root
  end
  def self.application_root=(path)
    @application_root = path
  end
  def self.initialize_application_root
    self.application_root = defined?(Rails) ? Rails.root : '.'
  end
  def self.application_environment
    @application_environment = @application_environment || initialize_application_environment
  end
  def self.application_environment=(environment)
    @application_environment = environment
  end
  def self.initialize_application_environment
    self.application_environment = defined?(Rails) ? Rails.env.to_s : ENV['APP_ENV'] || 'development'
  end
  def self.logger
    @logger = @logger || initialize_logger
  end
  def self.logger=(logger)
    @logger = logger
  end
  def self.initialize_logger
    self.logger = defined?(Rails) && Rails.logger ? Rails.logger : Logger.new(STDOUT)
  end
  def self.environment_variable_overrides
    @environment_variable_overrides = (cacheable? && @environment_variable_overrides) || load_environment_variable_overrides
  end
  def self.load_environment_variable_overrides
    @environment_variable_overrides = featureize_keys(select_feature_keys(booleanize_values(downcase_keys(ENV))))
  end
  def self.local_features
    @local_features = (cacheable? && @local_features) || load_local_features
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
    @features = (cacheable? && @features) || load_features
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
    @environment_features = (cacheable? && @environment_features) || {}
    @environment_features[environment] = (cacheable? && @environment_features[environment]) || load_environment_features(environment)
  end
  def self.load_environment_features(environment)
    @environment_features = (cacheable? && @environment_features) || {}
    puts '-1. @environment_features.inspect'
    puts @environment_features.inspect
    puts '0. environment'
    puts environment.inspect
    puts '1. features[environment]'
    puts features[environment].inspect
    features[environment] = (cacheable? && features[environment]) || {}
    puts '1a cacheable?.inspect'
    puts cacheable?.inspect
    puts '2. features[environment]'
    puts features[environment].inspect
    local_features[environment] = (cacheable? && local_features[environment]) || {}

    puts 'local_features.inspect'
    puts local_features.inspect
    puts 'environment_variable_overrides.inspect'
    puts environment_variable_overrides.inspect
    @environment_features[environment] = features[environment].merge(local_features[environment]).merge(environment_variable_overrides)
  end
  def self.application_features
    environment_features(application_environment)
  end
  def self.load_application_features
    AbstractFeatureBranch.load_environment_variable_overrides
    AbstractFeatureBranch.load_features
    AbstractFeatureBranch.load_local_features
    AbstractFeatureBranch.load_environment_features(application_environment)
  end
  def self.cacheable?
    application_environment != 'development'
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
    Hash[hash.map {|k, v| [k, v.to_s.downcase == 'true']}]
  end

  def self.downcase_keys(hash)
    Hash[hash.map {|k, v| [k.to_s.downcase, v]}]
  end

  def self.downcase_feature_hash_keys(hash)
    Hash[(hash || {}).map {|k, v| [k, v && downcase_keys(v)]}]
  end
end

require File.join(File.dirname(__FILE__), 'ext', 'feature_branch')
require File.join(File.dirname(__FILE__), 'abstract_feature_branch', 'file_beautifier')
