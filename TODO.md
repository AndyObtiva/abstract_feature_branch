# TODO

## Future

- Ensure that per-user feature enablement does not happen live when `AbstractFeatureBranch.feature_store_live_fetching` is `false`
- Generalize per-user feature enablement to per-entity feature enablement by supporting a per_entity value and keeping per_user vaue support as an alias for backwards compatibility

- Web user interface for configuring Redis Overrides (tech details: could be implemented as a [Rails engine](https://guides.rubyonrails.org/engines.html) gem)
- Web user interface for configuring Environment Variable Overrides (tech details: could be implemented as a [Rails engine](https://guides.rubyonrails.org/engines.html) gem; configured data would disappear once server is restarted, which is by design when using Environment Variable Overrides)
- Support a Rails API for retrieving feature flags to simplify consumption of feature flags in SPAs with JavaScript Ajax/fetch calls
- Support a Rails Helper for embedding all feature flags in a document element to simplify their consumption in JavaScript code
- Support a Rails JavaScript object API for retrieving feature flags conveniently in JavaScript from feature flag document element
- Support a Rails JavaScript object API for retrieving feature flags conveniently in JavaScript from feature flag Rails API
- Detect if a feature got repeated in multiple context files and display a warning about it. Also, provide an option to fail fast in that scenario
- Provide official support or examples of how to Branch By Abstraction by using Inheritance, Strategy Design Pattern or Bridge Design Pattern based on whether a feature is enabled or not, or based on whether one of multiple related features is enabled exclusively.
