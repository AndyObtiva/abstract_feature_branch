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
require 'forwardable'

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'abstract_feature_branch/configuration'

module AbstractFeatureBranch
  ENV_FEATURE_PREFIX = "abstract_feature_branch_"
  REDIS_HKEY = "abstract_feature_branch"
  VALUE_SCOPED = 'scoped'
  SCOPED_SPECIAL_VALUES = [VALUE_SCOPED, 'per_user', 'per-user', 'per user']

  class << self
    extend Forwardable
    def_delegators :configuration, # delegating the following methods to configuration
                   :application_root, :application_root=, :initialize_application_root, :application_environment, :application_environment=, :initialize_application_environment,
                   :logger, :logger=, :initialize_logger, :cacheable, :cacheable=, :initialize_cacheable, :feature_store, :feature_store=, :user_features_storage, :user_features_storage=,
                   :feature_store_live_fetching, :feature_store_live_fetching=
    
    def configuration
      @configuration ||= Configuration.new
    end

    def redis_overrides
      @redis_overrides ||= load_redis_overrides
    end
    def load_redis_overrides
      return (@redis_overrides = {}) if feature_store.nil?
      
      redis_feature_hash = get_store_features.inject({}) do |output, feature|
        output.merge(feature => get_store_feature(feature))
      end
      
      @redis_overrides = downcase_keys(redis_feature_hash)
    rescue Exception => error
      AbstractFeatureBranch.logger.error "AbstractFeatureBranch encounter an error in loading Redis Overrides!\n\nError:#{error.full_message}\n\n"
      @redis_overrides = {}
    end

    def environment_variable_overrides
      @environment_variable_overrides ||= load_environment_variable_overrides
    end
    def load_environment_variable_overrides
      @environment_variable_overrides = featureize_keys(downcase_keys(booleanize_values(select_feature_keys(ENV))))
    end
    
    def local_features
      @local_features ||= load_local_features
    end
    def load_local_features
      @local_features = {}
      load_specific_features(@local_features, '.local.yml')
    end
    
    def features
      @features ||= load_features
    end
    def load_features
      @features = {}
      load_specific_features(@features, '.yml')
    end
    
    # performance optimization via caching of feature values resolved through environment variable overrides and local features
    def environment_features(environment)
      @environment_features ||= {}
      @environment_features[environment] ||= load_environment_features(environment)
    end
    def load_environment_features(environment)
      @environment_features ||= {}
      features[environment] ||= {}
      local_features[environment] ||= {}
      @environment_features[environment] = features[environment].
        merge(local_features[environment]).
        merge(environment_variable_overrides).
        merge(redis_overrides)
    end
    
    def redis_scoped_features
      @redis_scoped_features ||= load_redis_scoped_features
    end
    def load_redis_scoped_features
      @redis_scoped_features = {}
      return @redis_scoped_features if AbstractFeatureBranch.configuration.feature_store_live_fetching?
      
      @environment_features.each do |environment, features|
        features.each do |feature, value|
          if SCOPED_SPECIAL_VALUES.include?(value.to_s.downcase)
            normalized_feature_name = feature.to_s.downcase
            @redis_scoped_features[normalized_feature_name] ||= []
            begin
              @redis_scoped_features[normalized_feature_name] += scopes_for_feature(normalized_feature_name)
            rescue Exception => error
              AbstractFeatureBranch.logger.error "AbstractFeatureBranch encountered an error in retrieving Per-User values for feature \"#{normalized_feature_name}\"! Defaulting to no values...\n\nError: #{error.full_message}\n\n"
              nil
            end
          end
        end
      end
      
      @redis_scoped_features
    end
    
    def application_features
      unload_application_features unless cacheable?
      environment_features(application_environment)
    end
    def load_application_features
      AbstractFeatureBranch.load_redis_overrides
      AbstractFeatureBranch.load_environment_variable_overrides
      AbstractFeatureBranch.load_features
      AbstractFeatureBranch.load_local_features
      AbstractFeatureBranch.load_environment_features(application_environment)
      AbstractFeatureBranch.load_redis_scoped_features
    end
    def unload_application_features
      @redis_overrides = nil
      @environment_variable_overrides = nil
      @features = nil
      @local_features = nil
      @environment_features = nil
      @redis_scoped_features = nil
    end
    
    def cacheable?
      value = downcase_keys(cacheable)[application_environment]
      value = (application_environment != 'development') if value.nil?
      value
    end
    
    def scoped_value?(value)
      SCOPED_SPECIAL_VALUES.include?(value.to_s.downcase)
    end
    
    # Sets feature value (true or false) in storage (e.g. Redis client)
    def set_store_feature(feature, value)
      raise 'Feature storage (e.g. Redis) is not setup!' if feature_store.nil?
      feature = feature.to_s
      return delete_store_feature(feature) if value.nil?
      value = 'true' if value == true
      value = 'false' if value == false
      feature_store.hset(REDIS_HKEY, feature, value)
    end
    
    # Gets feature value (true or false) from storage (e.g. Redis client)
    def get_store_feature(feature)
      raise 'Feature storage (e.g. Redis) is not setup!' if feature_store.nil?
      feature = feature.to_s
      value = feature_store.hget(REDIS_HKEY, feature)
      if value.nil?
        matching_feature = get_store_features.find { |store_feature| store_feature.downcase == feature.downcase }
        value = feature_store.hget(REDIS_HKEY, matching_feature) if matching_feature
      end
      return nil if value.nil?
      return VALUE_SCOPED if scoped_value?(value)
      value.to_s.downcase == 'true'
    end
    
    # Gets feature value (true or false) from storage (e.g. Redis client)
    def delete_store_feature(feature)
      raise 'Feature storage (e.g. Redis) is not setup!' if feature_store.nil?
      feature = feature.to_s
      feature_store.hdel(REDIS_HKEY, feature)
    end
    
    # Gets features array (all features) from storage (e.g. Redis client)
    def get_store_features
      raise 'Feature storage (e.g. Redis) is not setup!' if feature_store.nil?
      feature_store.hkeys(REDIS_HKEY)
    end
    
    # Gets features array (all features) from storage (e.g. Redis client)
    def clear_store_features
      raise 'Feature storage (e.g. Redis) is not setup!' if feature_store.nil?
      feature_store.hkeys(REDIS_HKEY).each do |feature|
        feature_store.hdel(REDIS_HKEY, feature)
      end
    end
    
    def toggle_features_for_scope(scope, features)
      features.each do |name, value|
        if value
          feature_store.sadd("#{ENV_FEATURE_PREFIX}#{name.to_s.downcase}", scope)
        else
          feature_store.srem("#{ENV_FEATURE_PREFIX}#{name.to_s.downcase}", scope)
        end
      end
    end
    alias toggle_features_for_user toggle_features_for_scope
    
    def toggled_features_for_scope(scope)
      AbstractFeatureBranch.feature_store.keys.select do |key|
        key.start_with?(AbstractFeatureBranch::ENV_FEATURE_PREFIX)
      end.map do |key|
        feature = key.sub(AbstractFeatureBranch::ENV_FEATURE_PREFIX, '')
      end.select do |feature|
        scopes_for_feature(feature).include?(scope.to_s)
      end
    end
    
    def scopes_for_feature(feature)
      normalized_feature_name = feature.to_s.downcase
      AbstractFeatureBranch.
        feature_store.
        smembers("#{AbstractFeatureBranch::ENV_FEATURE_PREFIX}#{normalized_feature_name}")
    end
    
    private

    def load_specific_features(features_hash, extension)
      Dir.glob(File.join(application_root, 'config', 'features', '**', "*#{extension}")).each do |feature_configuration_file|
        features_hash.deep_merge!(downcase_feature_hash_keys(YAML.load_file(feature_configuration_file)))
      end
      main_local_features_file = File.join(application_root, 'config', "features#{extension}")
      features_hash.deep_merge!(downcase_feature_hash_keys(YAML.load_file(main_local_features_file))) if File.exists?(main_local_features_file)
      features_hash
    end

    def featureize_keys(hash)
      Hash[hash.map {|k, v| [k.sub(ENV_FEATURE_PREFIX, ''), v]}]
    end

    def select_feature_keys(hash)
      hash.reject {|k, v| !k.downcase.start_with?(ENV_FEATURE_PREFIX)} # using reject for Ruby 1.8 compatibility as select returns an array in it
    end

    def booleanize_values(hash)
      hash_values = hash.map do |k, v|
        normalized_value = v.to_s.downcase
        boolean_value = normalized_value == 'true'
        new_value = scoped_value?(normalized_value) ? VALUE_SCOPED : boolean_value
        [k, new_value]
      end
      Hash[hash_values]
    end

    def downcase_keys(hash)
      Hash[hash.map {|k, v| [k.to_s.downcase, v]}]
    end

    def downcase_feature_hash_keys(hash)
      Hash[(hash || {}).map {|k, v| [k, v && downcase_keys(v)]}]
    end
  end
end

require File.join(File.dirname(__FILE__), 'ext', 'feature_branch')
require File.join(File.dirname(__FILE__), 'abstract_feature_branch', 'file_beautifier')
