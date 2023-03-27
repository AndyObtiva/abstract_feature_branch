require 'abstract_feature_branch/memoizable'
require 'abstract_feature_branch/redis/connection_pool_to_redis_adapter'

module AbstractFeatureBranch
  class Configuration
    include Memoizable
    
    MUTEX = {
      '@application_root': Mutex.new,
      '@application_environment': Mutex.new,
      '@logger': Mutex.new,
      '@cacheable': Mutex.new,
      '@feature_store_live_fetching': Mutex.new,
    }
  
    def application_root
      memoize_thread_safe(:@application_root, :initialize_application_root)
    end
    def application_root=(path)
      @application_root = path
    end
    def initialize_application_root
      self.application_root = defined?(Rails) ? Rails.root : '.'
    end
    def application_environment
      memoize_thread_safe(:@application_environment, :initialize_application_environment)
    end
    def application_environment=(environment)
      @application_environment = environment
    end
    def initialize_application_environment
      self.application_environment = defined?(Rails) ? Rails.env.to_s : ENV['APP_ENV'] || 'development'
    end
    def logger
      memoize_thread_safe(:@logger, :initialize_logger)
    end
    def logger=(logger)
      @logger = logger
    end
    def initialize_logger
      self.logger = defined?(Rails) && Rails.logger ? Rails.logger : Logger.new(STDOUT)
    end
    def cacheable
      memoize_thread_safe(:@cacheable, :initialize_cacheable)
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
      @feature_store
    end
    alias user_features_storage feature_store
    
    def feature_store=(feature_store)
      if feature_store.nil?
        @feature_store = nil
      else
        begin
          @feature_store = feature_store.is_a?(::ConnectionPool) ? AbstractFeatureBranch::Redis::ConnectionPoolToRedisAdapter.new(feature_store) : feature_store
        rescue NameError => e
          logger.debug { "connection_pool gem is not available" }
          @feature_store = feature_store
        end
      end
    end
    alias user_features_storage= feature_store=
    
    def feature_store_live_fetching
      memoize_thread_safe(:@feature_store_live_fetching, :initialize_feature_store_live_fetching)
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
