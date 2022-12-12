require 'abstract_feature_branch/redis/connection_pool_to_redis_adapter'

module AbstractFeatureBranch
  class Configuration
    def application_root
      @application_root ||= initialize_application_root
    end
    def application_root=(path)
      @application_root = path
    end
    def initialize_application_root
      self.application_root = defined?(Rails) ? Rails.root : '.'
    end
    def application_environment
      @application_environment ||= initialize_application_environment
    end
    def application_environment=(environment)
      @application_environment = environment
    end
    def initialize_application_environment
      self.application_environment = defined?(Rails) ? Rails.env.to_s : ENV['APP_ENV'] || 'development'
    end
    def logger
      @logger ||= initialize_logger
    end
    def logger=(logger)
      @logger = logger
    end
    def initialize_logger
      self.logger = defined?(Rails) && Rails.logger ? Rails.logger : Logger.new(STDOUT)
    end
    def cacheable
      @cacheable ||= initialize_cacheable
    end
    def cacheable=(cacheable)
      @cacheable = cacheable
    end
    def initialize_cacheable
      self.cacheable = {
        :development => false,
        :test => true,
        :staging => true,
        :production => true
      }
    end
    
    def feature_store
      @feature_store ||= initialize_feature_store
    end
    alias user_features_storage feature_store
    
    def feature_store=(feature_store)
      if feature_store.nil?
        @feature_store = nil
      else
        @feature_store = feature_store.is_a?(::ConnectionPool) ? AbstractFeatureBranch::Redis::ConnectionPoolToRedisAdapter.new(feature_store) : feature_store
      end
    end
    alias user_features_storage= feature_store=
    
    def initialize_feature_store
      self.feature_store = ::Redis.new
    rescue => e
      logger.debug { "Redis is not enabled!" }
      logger.debug { e.full_message }
      nil
    end
    alias initialize_user_features_storage initialize_feature_store
    
    def feature_store_live_fetching
      initialize_feature_store_live_fetching if @feature_store_live_fetching.nil?
      @feature_store_live_fetching
    end
    alias feature_store_live_fetching? feature_store_live_fetching
    
    def feature_store_live_fetching=(value)
      @feature_store_live_fetching = value
    end
    
    def initialize_feature_store_live_fetching
      @feature_store_live_fetching = false
    end
  end
end
