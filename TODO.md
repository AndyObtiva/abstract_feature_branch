# TODO

## Future

- Fix error regarding failed Hash merge on features[environment] caused by code not being safe for multi-threading
- Write tests to confirm that AbstractFeatureBranch is thread-safe

- Support `feature_disabled?` alternative to `feature_enabled?` to offer better readability than `!feature_enabled?(:some_feature)`
- Support `disabled_feature_branch(:some_feature) do; end` as the opposite of `feature_branch(:some_feature) do; end`
- Support new configuration option `AbstractFeatureBranch.feature_store_per_user_live_fetching` to have the ability to enable per-user only live loading from feature store (i.e. Redis) by taking precedence over the `AbstractFeatureBranch.feature_store_live_fetching` configuration option (which affects both general and per-user feature loading)

- Web user interface for configuring Redis Overrides (tech details: could be implemented as a [Rails engine](https://guides.rubyonrails.org/engines.html) gem)
- Web user interface for configuring Environment Variable Overrides (tech details: could be implemented as a [Rails engine](https://guides.rubyonrails.org/engines.html) gem; configured data would disappear once server is restarted, which is by design when using Environment Variable Overrides)
- Support a Rails Helper or Partial to pull in all feature flags (making the variable name customizable):
<% AbstractFeatureBranch.application_features.each do |feature, value| %>
  <%= tag :meta, name: "feature_#{feature}", content: value %>
<% end %>

<script>
  window.abstract_feature_branch_features = {}
  document.head.querySelectorAll('meta[name^=feature_]').forEach((element) => {
    const feature = element.name.match(/^feature_(.*)$/)[1]
    const value = element.content.toLowerCase() == 'true'
    window.abstract_feature_branch_features[feature] = value
  })
</script>

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

## Issues

- Fix this issue: /~/.rvm/gems/ruby-3.1.4@Lexop/gems/abstract_feature_branch-1.6.0/lib/ext/feature_branch.rb:15:in `feature_enabled?': undefined method `[]' for nil:NilClass (NoMethodError)

      value = !redis_override_value.nil? ? redis_override_value : AbstractFeatureBranch.application_features[normalized_feature_name]
                                                                                                            ^^^^^^^^^^^^^^^^^^^^^^^^^
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/abstract_feature_branch-1.6.0/lib/ext/feature_branch.rb:58:in `feature_enabled?'
	from /~/code/lexop/lib/core_extensions/sidekiq/client.rb:7:in `push'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/worker.rb:360:in `client_push'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/worker.rb:198:in `perform_async'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/worker.rb:289:in `perform_async'
	from /~/code/lexop/app/middleware/sidekiq_middleware.rb:94:in `block (2 levels) in enqueue_job_in_all_shards'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/activerecord-7.0.8/lib/active_record/connection_handling.rb:374:in `with_role_and_shard'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/activerecord-7.0.8/lib/active_record/connection_handling.rb:156:in `connected_to'
	from /~/code/lexop/app/middleware/sidekiq_middleware.rb:93:in `block in enqueue_job_in_all_shards'
	from /~/code/lexop/app/middleware/sidekiq_middleware.rb:92:in `each'
	from /~/code/lexop/app/middleware/sidekiq_middleware.rb:92:in `enqueue_job_in_all_shards'
	from /~/code/lexop/app/middleware/sidekiq_middleware.rb:14:in `call'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/middleware/chain.rb:179:in `block in invoke'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/i18n-1.14.1/lib/i18n.rb:322:in `with_locale'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/middleware/i18n.rb:24:in `call'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/middleware/chain.rb:179:in `block in invoke'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/rollbar-3.4.2/lib/rollbar/plugins/sidekiq/plugin.rb:11:in `call'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/middleware/chain.rb:179:in `block in invoke'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-pro-5.5.8/lib/sidekiq/batch/middleware.rb:58:in `call'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/middleware/chain.rb:179:in `block in invoke'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-ent-2.5.3/lib/sidekiq-ent/unique.rb:154:in `call'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/middleware/chain.rb:179:in `block in invoke'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-ent-2.5.3/lib/sidekiq-ent/limiter/middleware.rb:39:in `call'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/middleware/chain.rb:179:in `block in invoke'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/middleware/chain.rb:182:in `invoke'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:169:in `block in process'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:136:in `block (6 levels) in dispatch'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/job_retry.rb:113:in `local'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:135:in `block (5 levels) in dispatch'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/rails.rb:14:in `block in call'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/activesupport-7.0.8/lib/active_support/execution_wrapper.rb:92:in `wrap'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/activesupport-7.0.8/lib/active_support/reloader.rb:72:in `block in wrap'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/activesupport-7.0.8/lib/active_support/execution_wrapper.rb:92:in `wrap'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/activesupport-7.0.8/lib/active_support/reloader.rb:71:in `wrap'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/rails.rb:13:in `call'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:131:in `block (4 levels) in dispatch'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:263:in `stats'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:126:in `block (3 levels) in dispatch'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/job_logger.rb:13:in `call'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:125:in `block (2 levels) in dispatch'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/job_retry.rb:80:in `global'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:124:in `block in dispatch'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/job_logger.rb:39:in `prepare'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:123:in `dispatch'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:168:in `process'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:78:in `process_one'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/processor.rb:68:in `run'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/component.rb:8:in `watchdog'
	from /~/.rvm/gems/ruby-3.1.4@Lexop/gems/sidekiq-6.5.12/lib/sidekiq/component.rb:17:in `block in safe_thread'
