class Object
  raise 'Abstract feature branch conflicts with another Ruby library' if respond_to?(:feature_branch)
  def self.feature_branch(feature_name, branches = {}, &feature_work)
    branches[:true] ||= feature_work
    branches[:false] ||= lambda {}
    feature_status = AbstractFeatureBranch::FEATURES[Rails.env.to_s][feature_name.to_s].to_s.to_sym
    branches[feature_status].call
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if respond_to?(:feature_enabled?)
  def self.feature_enabled?(feature_name)
    AbstractFeatureBranch::FEATURES[Rails.env.to_s][feature_name.to_s]
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if Object.new.respond_to?(:feature_branch)
  def feature_branch(feature_name, branches = {}, &feature_work)
    Object.feature_branch(feature_name.to_s, branches, &feature_work)
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if Object.new.respond_to?(:feature_enabled?)
  def feature_enabled?(feature_name)
    Object.feature_enabled?(feature_name.to_s)
  end
end