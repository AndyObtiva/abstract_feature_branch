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
    def user_features_storage
      @user_features_storage ||= initialize_user_features_storage
    end
    def user_features_storage=(user_features_storage)
      @user_features_storage = user_features_storage
    end
    def initialize_user_features_storage
      self.user_features_storage = Redis.new
    rescue => e
      logger.debug "Redis is not enabled!"
      logger.debug e.full_message
      nil
    end
  end
end
