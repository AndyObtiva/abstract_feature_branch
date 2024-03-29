class Object
  class << self
    raise 'Abstract feature branch conflicts with another Ruby library having Object::feature_branch' if respond_to?(:feature_branch)
    def feature_branch(feature_name, scope = nil, &feature_work)
      if feature_enabled?(feature_name, scope)
        feature_work.call
      end
    end
  
    raise 'Abstract feature branch conflicts with another Ruby library having Object::feature_enabled?' if respond_to?(:feature_enabled?)
    def feature_enabled?(feature_name, scope = nil)
      normalized_feature_name = feature_name.to_s.downcase
  
      redis_override_value = feature_enabled_reddis_override_value(normalized_feature_name)
      value = !redis_override_value.nil? ? redis_override_value : AbstractFeatureBranch.application_features[normalized_feature_name]
      if AbstractFeatureBranch.scoped_value?(value)
        value = !scope.nil? && feature_enabled_scoped_value(feature_name, scope)
      end
      value
    end
  
    private
    
    raise 'Abstract feature branch conflicts with another Ruby library having Object::feature_enabled_reddis_override_value' if Object.new.respond_to?(:feature_enabled_reddis_override_value, true)
    def feature_enabled_reddis_override_value(normalized_feature_name)
      if AbstractFeatureBranch.configuration.feature_store_live_fetching?
        begin
          AbstractFeatureBranch.get_store_feature(normalized_feature_name)
        rescue Exception => error
          AbstractFeatureBranch.logger.error "AbstractFeatureBranch encountered an error in retrieving Redis Override value for feature \"#{normalized_feature_name}\"! Defaulting to YAML configuration value...\n\nError: #{error.full_message}\n\n"
          nil
        end
      end
    end
    
    raise 'Abstract feature branch conflicts with another Ruby library having Object::feature_enabled_scoped_value' if Object.new.respond_to?(:feature_enabled_scoped_value, true)
    def feature_enabled_scoped_value(normalized_feature_name, scope)
      if AbstractFeatureBranch.configuration.feature_store_live_fetching?
        begin
          AbstractFeatureBranch.feature_store.sismember("#{AbstractFeatureBranch::ENV_FEATURE_PREFIX}#{normalized_feature_name}", scope)
        rescue Exception => error
          AbstractFeatureBranch.logger.error "AbstractFeatureBranch encountered an error in retrieving Per-User value for feature \"#{normalized_feature_name}\" and scope #{scope}! Defaulting to nil value...\n\nError: #{error.full_message}\n\n"
          nil
        end
      else
        AbstractFeatureBranch.redis_scoped_features[normalized_feature_name]&.include?(scope.to_s)
      end
    end
  end
  
  raise 'Abstract feature branch conflicts with another Ruby library having Object#feature_branch' if Object.new.respond_to?(:feature_branch)
  def feature_branch(feature_name, scope = nil, &feature_work)
    Object.feature_branch(feature_name.to_s, scope, &feature_work)
  end

  raise 'Abstract feature branch conflicts with another Ruby library having Object#feature_enabled?' if Object.new.respond_to?(:feature_enabled?)
  def feature_enabled?(feature_name, scope = nil)
    Object.feature_enabled?(feature_name.to_s, scope)
  end
end
