class Object
  raise 'Abstract feature branch conflicts with another Ruby library' if respond_to?(:feature_branch)
  def self.feature_branch(feature_name, user_id = nil, &feature_work)
    if feature_enabled?(feature_name, user_id)
      feature_work.call
    end
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if respond_to?(:feature_enabled?)
  def self.feature_enabled?(feature_name, user_id = nil)
    normalized_feature_name = feature_name.to_s.downcase

    value = AbstractFeatureBranch.application_features[normalized_feature_name]
    if value == 'per_user'
      value = AbstractFeatureBranch.user_features_storage.sismember("#{AbstractFeatureBranch::ENV_FEATURE_PREFIX}#{normalized_feature_name}", user_id)
    end
    value
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if Object.new.respond_to?(:feature_branch)
  def feature_branch(feature_name, user_id = nil, &feature_work)
    Object.feature_branch(feature_name.to_s, user_id, &feature_work)
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if Object.new.respond_to?(:feature_enabled?)
  def feature_enabled?(feature_name, user_id = nil)
    Object.feature_enabled?(feature_name.to_s, user_id)
  end
end