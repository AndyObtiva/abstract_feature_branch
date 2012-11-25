class Object
  raise 'Abstract feature branch conflicts with another Ruby library' if respond_to?(:feature_branch)
  def self.feature_branch(feature_name, branches = {}, &feature_work)
    branches[:true] ||= feature_work
    branches[:false] ||= lambda {}
    feature_status = Settings[Rails.env.to_s]['features'][feature_name].to_s.to_sym
    branches[feature_status].call
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if respond_to?(:feature_enabled?)
  def self.feature_enabled?(feature_name)
    Settings[Rails.env.to_s]['features'][feature_name]
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if Object.new.respond_to?(:feature_branch)
  def feature_branch(feature_name, branches = {}, &feature_work)
    Object.feature_branch(feature_name, branches, &feature_work)
  end

  raise 'Abstract feature branch conflicts with another Ruby library' if Object.new.respond_to?(:feature_enabled?)
  def feature_enabled?(feature_name)
    Object.feature_enabled?(feature_name)
  end
end