# Storage system for features (other than YAML/Env-Vars). Right now, only Redis and ConnectionPool are supported.
# AbstractFeatureBranch.feature_store = Redis.new

# Storage can be a Redis ConnectionPool instance
# AbstractFeatureBranch.feature_store = ConnectionPool.new { Redis.new }

# The following example line works with Heroku Redis To Go while still operating on local Redis for local development
# AbstractFeatureBranch.feature_store = Redis.new(:url => ENV['REDISTOGO_URL'])

# Enable live fetching of feature configuration from storage system (Redis), to update features without app/server restart.
# false by default to only load features on app/server start for faster performance (requires restart on change)
# This also affects scoped feature loading from storage system (Redis), pre-caching scope IDs for features on app/server
# restart when false, for better performance.
AbstractFeatureBranch.feature_store_live_fetching = false

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
