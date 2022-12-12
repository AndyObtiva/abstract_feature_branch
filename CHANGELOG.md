# Change Log

## 1.3.2

- Ensure better performance, fetch Redis Overrides at app/server startup time only by default while providing option to fetch live by setting `AbstractFeatureBranch.feature_store_live_fetching` to `true`
- Do not automatically pre-init `AbstractFeatureBranch.feature_store` with `Redis.new` if it was `nil` as that is a bad default.

## 1.3.1

- Support Redis `ConnectionPool` `AbstractFeatureBranch::Configuration#feature_store`

## 1.3.0

- Officially support newer `redis` client gem version 5
- Support (general-user) Redis Overrides (similar to Environment Variable Overrides)
- Remove `redis` gem from required dependencies to allow using `abstract_feature_branch` without Redis
- Make configuration of Redis optional in generated Rails initializer
- Provide alias of `AbstractFeatureBranch::Configuration#feature_store` to `AbstractFeatureBranch::Configuration#user_features_storage` (plus corresponding aliases `feature_store=` and `initialize_feature_store`)
- Document support for Rails 7 and Redis Server 7
- Add gem post install instructions, including how to run the Rails generators and install/use Redis
