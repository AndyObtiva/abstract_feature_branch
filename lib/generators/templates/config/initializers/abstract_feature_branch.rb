# Storage for user features, customizable over here. Right now, only a Redis client is supported.
# AbstractFeatureBranch.user_features_storage = Redis.new

# The following example line works with Heroku Redis To Go while still operating on local Redis for local development
# AbstractFeatureBranch.user_features_storage = Redis.new(:url => ENV['REDISTOGO_URL'])

# Application root where config/features.yml or config/features/ is found
AbstractFeatureBranch.application_root = Rails.root

# Application environment (e.g. "development", "staging" or "production")
AbstractFeatureBranch.application_environment = Rails.env.to_s

# Abstract Feature Branch logger
AbstractFeatureBranch.logger = Rails.logger

# Cache feature files once read or re-read them at runtime on every use (helps development).
# Defaults to true if environment not specified, except for development, which defaults to false.
AbstractFeatureBranch.cacheable = {
  :development => false,
  :test => true,
  :staging => true,
  :production => true
}

# Pre-load application features to improve performance of first web-page hit
AbstractFeatureBranch.load_application_features unless Rails.env.development?
