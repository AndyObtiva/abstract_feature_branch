# Application root where config/features.yml or config/features/ is found
AbstractFeatureBranch.application_root = Rails.root

# Application environment (e.g. "development", "staging" or "production")
AbstractFeatureBranch.application_environment = Rails.env.to_s

# Pre-loads application features to improve performance of first web-page hit
AbstractFeatureBranch.load_application_features