class Object
  raise 'Abstract feature branch conflicts with another Ruby library' if respond_to?(:feature_branch)
  def self.feature_branch(feature_name, branches = {}, &feature_work)
    branches[:true] ||= feature_work
    branches[:false] ||= lambda {}
    feature_status = abstract_feature_branch_environment_value(feature_name)
    feature_status = AbstractFeatureBranch.features[Rails.env.to_s][feature_name.to_s] if feature_status.nil?
    feature_status = false if feature_status.nil?
    branches[feature_status.to_s.to_sym].call
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if respond_to?(:feature_enabled?)
  def self.feature_enabled?(feature_name)
    AbstractFeatureBranch.features[Rails.env.to_s][feature_name.to_s]
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if Object.new.respond_to?(:feature_branch)
  def feature_branch(feature_name, branches = {}, &feature_work)
    Object.feature_branch(feature_name.to_s, branches, &feature_work)
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if Object.new.respond_to?(:feature_enabled?)
  def feature_enabled?(feature_name)
    Object.feature_enabled?(feature_name.to_s)
  end

  private

  ABSTRACT_FEATURE_BRANCH_POSITIVE_VALUES = ['true', 'on', 'yes']

  raise 'Abstract feature branch conflicts with another Ruby library' if respond_to?(:abstract_feature_branch_environment_value)
  def self.abstract_feature_branch_environment_value(feature_name)
    downcased_env = Hash[ENV.map {|k, v| [k.downcase, v]}]
    value = downcased_env["abstract_feature_branch_#{feature_name.to_s.downcase}"]
    value && ABSTRACT_FEATURE_BRANCH_POSITIVE_VALUES.include?(value.downcase)
  end
end