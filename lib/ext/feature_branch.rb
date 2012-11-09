class Object
  raise 'Abstract branch conflicts with another Ruby library' if respond_to?(:feature_branch)
  def self.feature_branch(feature_name, &feature_work)
    if Settings[Rails.env.to_s]['features'][feature_name]
      feature_work.call
    end
  end

  raise 'Abstract branch conflicts with another Ruby library' if Object.new.respond_to?(:feature_branch)
  def feature_branch(feature_name, &feature_work)
    Object.feature_branch(feature_name, &feature_work)
  end
end