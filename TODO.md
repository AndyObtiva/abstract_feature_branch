# TODO

## Future

- Fix error regarding failed Hash merge on features[environment] caused by code not being safe for multi-threading
- Write tests to confirm that AbstractFeatureBranch is thread-safe

- Support new configuration option `AbstractFeatureBranch.feature_store_per_user_live_fetching` to have the ability to enable per-user only live loading from feature store (i.e. Redis) by taking precedence over the `AbstractFeatureBranch.feature_store_live_fetching` configuration option (which affects both general and per-user feature loading)

- Web user interface for configuring Redis Overrides (tech details: could be implemented as a [Rails engine](https://guides.rubyonrails.org/engines.html) gem)
- Web user interface for configuring Environment Variable Overrides (tech details: could be implemented as a [Rails engine](https://guides.rubyonrails.org/engines.html) gem; configured data would disappear once server is restarted, which is by design when using Environment Variable Overrides)
- Support a Rails API for retrieving feature flags to simplify consumption of feature flags in SPAs with JavaScript Ajax/fetch calls
- Support a Rails Helper for embedding all feature flags in a document element to simplify their consumption in JavaScript code
- Support a Rails JavaScript object API for retrieving feature flags conveniently in JavaScript from feature flag document element
- Support a Rails JavaScript object API for retrieving feature flags conveniently in JavaScript from feature flag Rails API
- Detect if a feature got repeated in multiple context files and display a warning about it. Also, provide an option to fail fast in that scenario
- Provide official support or examples of how to Branch By Abstraction by using Inheritance, Strategy Design Pattern or Bridge Design Pattern based on whether a feature is enabled or not, or based on whether one of multiple related features is enabled exclusively.
- Programmatic in-memory setting of feature flags via Ruby API (different from env var overrides and redis overrides)

## Maybe

- Support feature strategies (multiple possible string values instead of true and false) with feature_strategy method to use instead of feature_enabled?
- Support integrating feature strategies with the strategic ruby gem to instantiate models with strategies configured in abstract feature branch. That would yield a fully authentic application of the Branch By Abstraction pattern
- live switching support for live loading or not
- independent switch for live loading and live per user loading
- rake task for generating *.local.yml file for a specific feature.yml file
- rake task for generating all *.local.yml files
- rake task for resetting *.local.yml file for a specific feature.yml file
- rake task for resetting all *.local.yml files
