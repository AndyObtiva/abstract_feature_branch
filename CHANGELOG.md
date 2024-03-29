# Change Log

## 1.6.0

- Support Ruby 3.3 - Ruby 1.9.1
- Thread-Safe Support for Multi-Threaded Usage of `feature_enabled?` and `feature_branch` (fixes issue with multi-threaded usage of `feature_enabled?` causing a `merge` method invocation error due to a `features[environment]` `nil` value that should have been a `Hash` value instead)

## 1.5.1

- `AbstractFeatureBranch.toggled_features_for_scope(scope)` API method that returns toggled features for a scope (String)
- `AbstractFeatureBranch.scopes_for_feature(feature)` API method that returns scopes for a (scoped) feature (String or Symbol)

## 1.5.0

- Generalize "Per-User Feature Enablement" as "Scoped Feature Enablement" (using `scoped` value instead of `per_user` value) to scope features by any scope IDs (e.g. entity IDs or value objects)
- Rename `toggle_features_for_user` to `toggle_features_for_scope`

## 1.4.0

- Avoid live loading of per-user features when `AbstractFeatureBranch.feature_store_live_fetching` is `false` to ensure better performance through caching.

## 1.3.3

- Redis network failure error handling for per-user feature enablement to default to `nil` value instead of crashing
- Error logging upon encountering Redis network failure errors in loading Redis Overrides live or not and in per-user feature enablement

## 1.3.2

- Ensure better performance, fetch Redis Overrides at app/server startup time only by default while providing option to fetch live by setting `AbstractFeatureBranch.feature_store_live_fetching` to `true`
- Do not automatically pre-init `AbstractFeatureBranch.feature_store` with `Redis.new` if it was `nil` as that is a bad default.
- Fix issue with crashing when not including the `connection_pool` gem manually if needed with a version of `redis` older than 5

## 1.3.1

- Support Redis `ConnectionPool` `AbstractFeatureBranch::Configuration#feature_store`

## 1.3.0

- Officially support newer `redis` client gem version 5
- Support (general-user) Redis Overrides (similar to Environment Variable Overrides)
- Remove `redis` gem from required dependencies to allow using `abstract_feature_branch` without Redis
- Make configuration of Redis optional in generated Rails initializer
- Provide alias of `AbstractFeatureBranch::Configuration#feature_store` to `AbstractFeatureBranch::Configuration#user_features_storage` (plus corresponding aliases `feature_store=` and `initialize_feature_store`)
- Document support for Ruby 3.1, Rails 7 and Redis Server 7
- Add gem post install instructions, including how to run the Rails generators and install/use Redis
