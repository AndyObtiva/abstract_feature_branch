# Change Log

## 1.3.0

- Officially support newer `redis` client gem version 5
- Support `redis` (general-user) overrides (similar to environment variable overrides)
- Remove `redis` gem from required dependencies
- Make Redis optional in generated Rails initializer
- Provide alias of `AbstractFeatureBranch::Configuration#feature_store` to `AbstractFeatureBranch::Configuration#user_features_storage` (plus corresponding aliases `feature_store=` and `initialize_feature_store`)
- Document support for Rails 7 and Redis Server 7
