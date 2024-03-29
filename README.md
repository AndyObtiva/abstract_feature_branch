# Abstract Feature Branch 1.6.0
[![Gem Version](https://badge.fury.io/rb/abstract_feature_branch.png)](http://badge.fury.io/rb/abstract_feature_branch)
[![Build Status](https://api.travis-ci.org/AndyObtiva/abstract_feature_branch.png?branch=master)](https://travis-ci.org/AndyObtiva/abstract_feature_branch)
[![Coverage Status](https://coveralls.io/repos/AndyObtiva/abstract_feature_branch/badge.png?branch=master)](https://coveralls.io/r/AndyObtiva/abstract_feature_branch?branch=master)
[![Code Climate](https://codeclimate.com/github/AndyObtiva/abstract_feature_branch.png)](https://codeclimate.com/github/AndyObtiva/abstract_feature_branch)

[`abstract_feature_branch`](https://rubygems.org/gems/abstract_feature_branch) is a Ruby gem that provides a unique variation on the [Branch by Abstraction Pattern](http://paulhammant.com/blog/branch_by_abstraction.html) by [Paul Hammant](https://paulhammant.com/) and the [Feature Toggles Pattern](https://martinfowler.com/bliki/FeatureToggle.html) by [Martin Fowler](https://martinfowler.com/) to enhance team productivity and improve software fault tolerance.

It provides the ability to wrap blocks of code with an abstract feature branch name, and then
[specify in a configuration file](#instructions) which features to be switched on or off.

The goal is to build out upcoming features in the same source code repository branch (i.e. [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration) and [Trunk-Based Development](https://trunkbaseddevelopment.com)), regardless of whether all are
completed by the next release date or not, thus increasing team productivity by preventing integration delays.
Developers then disable in-progress features until they are ready to be switched on in production, yet enable them
locally and in staging environments for in-progress testing.

This gives developers the added benefit of being able to switch a feature off after release should big problems arise
for a high risk feature.

[`abstract_feature_branch`](https://rubygems.org/gems/abstract_feature_branch) additionally supports [Domain Driven Design](https://en.wikipedia.org/wiki/Domain-driven_design)'s pattern of
[Bounded Contexts](https://www.domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf) by allowing developers to configure
context-specific feature files if needed.

[`abstract_feature_branch`](https://rubygems.org/gems/abstract_feature_branch) is one of the simplest and most minimalistic "Feature Flags" Ruby gems out there as it enables you to get started very quickly by simply leveraging YAML files without having to set up a data store if you do not need it (albeit, you also have the option to use [Redis](https://redis.com) as a very fast in-memory data store).

Requirements
------------
- Ruby (between `~> 3.3.0` and `~> 1.9.1`)
- [Optional] Rails (between `~> 7.0` and `~> 2.0`)
- [Optional] Redis Server (between `~> 7.0` and `~> 2.0`)
- [Optional] Redis client gem (between `~> 5.0` and `~> 3.0`)

Setup
-----

### Rails Application Use

1. Configure Rubygem
   - With `rails` between `~> 7.0` and `~> 2.0`: Add the following to Gemfile <pre>gem 'abstract_feature_branch', '~> 1.6.0'</pre>
   - With `rails` `~> 2.0` only: Add the following to config/environment.rb <pre>config.gem 'abstract_feature_branch', :version => '1.6.0'</pre>
2. Generate <code>config/initializers/abstract_feature_branch.rb</code>, <code>lib/tasks/abstract_feature_branch.rake</code>, <code>config/features.yml</code> and <code>config/features.local.yml</code> in your Rails app directory by running <pre>rails g abstract_feature_branch:install</pre>
3. [Optional] Generate <code>config/features/[context_path].yml</code> in your Rails app directory by running <pre>rails g abstract_feature_branch:context context_path</pre> (more details under [**instructions**](#instructions))
4. [Optional] Customize configuration in <code>config/initializers/abstract_feature_branch.rb</code> (can be useful for changing location of feature files in Rails application, configuring Redis with a Redis or ConnectionPool instance to use for overrides, and [scoped feature enablement](#scoped-feature-enablement) (e.g. per-user), or troubleshooting a specific Rails environment feature configuration)
5. [Optional] Redis Server (between `~> 7.0` and `~> 3.0`): On the Mac, you can install simply via [Homebrew](https://brew.sh/) with `brew install redis`
6. [Optional] `redis` client gem (between `~> 5.0` and `~> 3.0`): Add the following to Gemfile above [`abstract_feature_branch`](https://rubygems.org/gems/abstract_feature_branch) <pre>gem 'redis', '~> 5.0.5'</pre>

### Ruby Application General Use

1. <pre>gem install abstract_feature_branch -v 1.6.0</pre>
2. Add code <code>require 'abstract_feature_branch'</code>
3. Create <code>config/features.yml</code> under <code>AbstractFeatureBranch.application_root</code> and fill it with content similar to that of the sample <code>config/features.yml</code> mentioned under [**instructions**](#instructions).
4. [Optional] Create <code>config/features.local.yml</code> under <code>AbstractFeatureBranch.application_root</code>  (more details under [**instructions**](#instructions))
5. [Optional] Create <code>config/features/[context_path].yml</code> under <code>AbstractFeatureBranch.application_root</code> (more details under [**instructions**](#instructions))
6. [Optional] Add code <code>AbstractFeatureBranch.application_root = "[your_application_path]"</code> to configure the location of feature files (it defaults to <code>'.'</code>)
7. [Optional] Add code <code>AbstractFeatureBranch.application_environment = "[your_application_environment]"</code> (it defaults to <code>'development'</code>). Alternatively, you can set <code>ENV['APP_ENV']</code> before the <code>require</code> statement or an an external environment variable.
8. [Optional] Add code <code>AbstractFeatureBranch.logger = "[your_application_logger]"</code> (it defaults to a new instance of Ruby <code>Logger</code>. Must use a logger with <code>info</code> and <code>warn</code> methods).
9. [Optional] Add code <code>AbstractFeatureBranch.cacheable = {[environment] => [true/false]}</code> to indicate cacheability of loaded feature files for enhanced performance (it defaults to true for every environment other than development).
10. [Optional] Add code <code>AbstractFeatureBranch.load_application_features</code> to pre-load application features for improved first-use performance
11. [Optional] Add code <code>AbstractFeatureBranch.feature_store = Redis.new(options)</code> to configure Redis for overrides and/or [scoped feature enablement](#scoped-feature-enablement) (e.g. per-user)
12. [Optional] Set <code>AbstractFeatureBranch.feature_store_live_fetching = true</code> to enable live fetching of features from store (e.g. Redis) to avoid need for app/server restart upon feature changes, with the trade-off of slightly more latency due to making calls to feature store over the network (this affects scoped feature enablement too, pre-caching all user IDs for features on app/server restart when disabled)

Instructions
------------

<code>config/features.yml</code> contains the main configuration for the application features.

<code>config/features.local.yml</code> contains local overrides for the configuration, ignored by git, thus useful for temporary
local feature switching for development/testing/troubleshooting purposes.

Optional context specific <code>config/features/[context_path].yml</code> contain feature configuration for specific application contexts.
For example: admin, public, or even internal/wiki. Useful for better organization especially once <code>config/features.yml</code> grows too big (e.g. 20+ features)

Optional context specific <code>config/features/[context_path].local.yml</code> contain local overrides for context-specific feature configuration.
These files are rarely necessary as any feature (even a context feature) can be overridden in <code>config/features.local.yml</code>,
so these additional <code>*.local.yml</code> files are only recommended to be utilized once <code>config/features.local.yml</code> grows
too big (e.g. 20+ features).

Here are the contents of the generated sample <code>config/features.yml</code>, which you can modify with your own features, each
enabled (true) or disabled (false) per environment (e.g. production).

>     defaults: &defaults
>       feature1: true
>       feature2: true
>       feature3: false
>       feature4: scoped
>
>     development:
>       <<: *defaults
>
>     test:
>       <<: *defaults
>
>     staging:
>       <<: *defaults
>       feature2: false
>
>     production:
>       <<: *defaults
>       feature1: false
>       feature2: false

Notice in the sample file how the feature "feature1" was configured as true (enabled) by default, but
overridden as false (disabled) in production. This is a recommended practice.

- Declaratively feature branch logic to only run when feature1 is enabled:

multi-line logic:
>     feature_branch :feature1 do
>       # perform logic
>     end

single-line logic:
>     feature_branch(:feature1) { # perform logic }

Note that <code>feature_branch</code> returns `nil` and does not execute the block if the feature is disabled or non-existent.

`feature_branch` supports multi-threaded code (i.e. usage from multiple parallel threads, as possible in JRuby).

- Imperatively check if a feature is enabled or not:

>     if feature_enabled?(:feature1)
>       # perform logic
>     else
>       # perform alternate logic
>     end

Note that <code>feature_enabled?</code> returns `false` if the feature is disabled and `nil` if the feature is non-existent (practically the same effect, but nil can sometimes be useful to detect if a feature is referenced).

`feature_enabled?` supports multi-threaded code (i.e. usage from multiple parallel threads, as possible in JRuby).

- List all configured features for a particular environment:

>     AbstractFeatureBranch.environment_features('development')
>     # => {"feature1"=>true, "feature2"=>false, "feature3"=>false, "feature4"=>true}

### Scoped Feature Enablement

It is possible to restrict enablement of features per specific users (or per entities of any kind) by setting a feature value to <code>scoped</code>, and then toggling features for specific users (or other entities).

1. Use <code>toggle_features_for_scope</code> in Ruby code to enable features per scope ID (e.g. entity ID, comma-separated compound ID, JSON string, or value object), which must be a String or a value that is safely-convertable to a String like Integer (e.g. email address or database ID). This loads Redis client gem into memory and stores scoped feature configuration in Redis.
In the example below, current_user is a method that provides the current signed in user (e.g. using Rails [Devise] (https://github.com/plataformatec/devise) library).

>     scope = current_user.email
>     AbstractFeatureBranch.toggle_features_for_scope(scope, :feature1 => true, :feature2 => false, :feature3 => true, :feature5 => true)

Use alternate version of <code>feature_branch</code> and <code>feature_enabled?</code> passing extra <code>scope</code> argument

Examples:

>     feature_branch :feature1, current_user.email do
>       # THIS WILL EXECUTE
>     end

>     if feature_enabled?(:feature2, current_user.email)
>       # THIS ONE WILL NOT EXECUTE
>     else
>       # THIS ONE WILL EXECUTE
>     end

>     feature_branch :feature1, another_user.email do
>       # THIS WILL NOT EXECUTE
>     end

>     if feature_enabled?(:feature2, another_user.email)
>       # THIS ONE WILL EXECUTE (assuming feature2 is enabled in features.yml)
>     else
>       # THIS ONE WILL NOT EXECUTE
>     end

Note:

If a feature is enabled as <code>true</code> or disabled as <code>false</code> in features.yml (or one of the overrides
like features.local.yml or environment variable overrides), then it overrides toggled scoped feature restrictions, becoming
enabled or disabled globally.

API
---

`AbstractFeatureBranch.toggle_features_for_scope(scope, feature1: true, feature2: false, ...)`: API method that toggles features (Strings or Symbols) for a scope

`AbstractFeatureBranch.toggled_features_for_scope(scope)`: API method that returns toggled features for a scope (String)

`AbstractFeatureBranch.scopes_for_feature(feature)`: API method that returns scopes for a (scoped) feature (String or Symbol)

Recommendations
---------------

- Wrap routes in routes.rb with feature blocks to disable entire MVC feature elements by
simply switching off the URL route to them. Example:

>     feature_branch :add_business_project do
>       resources :projects
>     end

- Wrap visual links to these routes in ERB views. Example:

>     <% feature_branch :add_business_project do %>
>       <h2>Submit a Business</h2>
>       <p>
>         Please submit a business idea for review.
>       </p>
>       <ul>
>         <% current_user.projects.each do |p| %>
>         <li><%= link_to p.business_campaign_name, project_path(p) %></li>
>         <% end %>
>       </ul>
>       <h4>
>         <%= link_to('Start', new_project_path, :id => "business_background_invitation", :class => 'button') %>
>       </h4>
>     <% end %>

- In Rails 4, wrap newly added strong parameters in controllers for data security. Example:

>     params.require(:project).permit(
>       feature_branch(:project_gallery) {:exclude_display},
>       :name,
>       :description,
>       :website
>     )

- In Rails 4 and 3.1+ with the asset pipeline, wrap newly added CSS or JavaScript using .erb format ([gotcha and alternative solution](#gotcha-with-abstract-feature-branching-in-css-and-js-files)). Example (renamed projects.css.scss to projects.css.scss.erb and wrapped CSS with an abstract feature branch block):

>     <% feature_branch :project_gallery do %>
>     .exclude_display {
>       margin-left: auto;
>       margin-right: auto;
>       label {
>         font-size: 1em;
>         text-align: center;
>       }
>       height: 47px;
>     }
>     <% end %>
>     label {
>       font-size: 1.5em;
>       margin-bottom: -15px;
>       margin-top: 3px;
>       display: inline;
>     }

- Once a feature has been released and switched on in production, and it has worked well for a while (e.g. for two consecutive releases),
it is **strongly recommended** that its feature branching code is plucked out of the codebase to simplify and improve
future maintainability given that it is no longer needed at that point.

- Once <code>config/features.yml</code> grows too big (e.g. 20+ features), it is **strongly recommended** to split it into
multiple context-specific feature files by utilizing the context generator mentioned above: <pre>rails g abstract_feature_branch:context context_path</pre>

- When working on a new feature locally that the developer does not want others on the team to see yet, the feature
can be enabled in <code>config/features.local.yml</code> only as it is git ignored while the feature is disabled in <code>config/features.yml</code>

- When troubleshooting a deployed feature by simulating a non-development environment (e.g. staging or production) locally,
the developer can disable it temporarily in <code>config/features.local.yml</code> (git ignored) under the non-development environment,
perform tests on the feature, and then remove the local configuration once done.

Environment Variable Overrides
------------------------------

You can override feature configuration with environment variables by setting an environment variable with
a name matching this convention (case-insensitive):
ABSTRACT_FEATURE_BRANCH_[feature_name] and giving it the case-insensitive value "TRUE" or "FALSE"

Example:

>     export ABSTRACT_FEATURE_BRANCH_FEATURE1=TRUE
>     rails s

The first command adds an environment variable override for <code>feature1</code> that enables it regardless of any
feature configuration, and the second command starts the rails server with <code>feature1</code> enabled.

To remove an environment variable override, you may run:

>     unset ABSTRACT_FEATURE_BRANCH_FEATURE1
>     rails s

The benefits can be achieved more easily via <code>config/features.local.yml</code> mentioned above.
However, environment variable overrides are implemented to support overriding feature configuration for a Heroku deployed
application more easily.

Redis Overrides
---------------

Prerequisites: Redis server and client (`redis` gem) and Redis configuration of `AbstractFeatureBranch.feature_store` in `config/initializers/abstract_feature_branch.rb` (`Redis` `ConnectionPool` instance is recommended for Production environments)

To be able to override feature configuration in a production environment, you can utilize Redis Overrides.

Alternatively, you may use Redis Overrides as your main source of feature configuration if you prefer that instead of relying on YAML files.

Keep in mind that by default, Redis Overrides are fetched on app/server start to pre-cache for better performance.

To enable live fetching of Redis Overrides, set `AbstractFeatureBranch#feature_store_live_fetching` to `true` (e.g. in `config/initializers/abstract_feature_branch.rb`), but keep in mind the trade-off with more latency due to making calls to Redis Server over the network.

You can override feature configuration with Redis hash values by calling `AbstractFeatureBranch#set_store_feature` in `rails console` (or `irb` after requiring `redis` and [`abstract_feature_branch`](https://rubygems.org/gems/abstract_feature_branch)):

```ruby
AbstractFeatureBranch.set_store_feature('feature1', true)
```

Behind the scenes, that is the equivalent of the following Redis client invocation, which stores a hash value in a `'abstract_feature_branch'` key:

```ruby
AbstractFeatureBranch.configuration.feature_store.hset('abstract_feature_branch', 'feature1', 'true')
```

To remove a Redis override, you can run the following in `rails console` (or `irb`):

```ruby
AbstractFeatureBranch.delete_store_feature('feature1')
```

To get a Redis override value, you can run the following in `rails console` (or `irb`):

```ruby
AbstractFeatureBranch.get_store_feature('feature1')
```

To get an array of all Redis Override features, you can run the following in `rails console` (or `irb`):

```ruby
AbstractFeatureBranch.get_store_features
```

Heroku
------

Environment variable overrides can be extremely helpful on Heroku as they allow developers to enable/disable features
at runtime without a redeploy.

### Examples

Enabling a new feature without a redeploy:
<pre>heroku config:add ABSTRACT_FEATURE_BRANCH_FEATURE3=true -a heroku_application_name</pre>

Disabling a buggy recently deployed feature without a redeploy:
<pre>heroku config:add ABSTRACT_FEATURE_BRANCH_FEATURE2=false -a heroku_application_name</pre>

Removing an environment variable override:
<pre>heroku config:remove ABSTRACT_FEATURE_BRANCH_FEATURE2 -a heroku_application_name</pre>

### Recommendation

It is recommended that you use environment variable overrides on Heroku only as an emergency or temporary measure.
Afterward, make the change official in config/features.yml, deploy, and remove the environment variable override for the long term.

### Gotcha with abstract feature branching in CSS and JS files

If you've used abstract feature branching in CSS or JS files via ERB, setting environment variable overrides won't
affect them as you need asset recompilation in addition to it, which can only be triggered by changing a CSS or JS
file and redeploying on Heroku (even if it's just a minor change to force it). In any case, environment variable
overrides have been recommended above as an emergency or temporary measure. If there is a need to rely on environment
variable overrides to alter the style or JavaScript behavior of a page back and forth without a redeploy, **one solution**
is to do additional abstract feature branching in HTML templates (e.g. ERB or [HAML](http://haml.info) to
link to different stylesheets and JS files, use different CSS classes, or invoke different JavaScript methods per branch
of HTML for example.)

Feature Configuration Load Order
--------------------------------

For better knowledge and clarity, here is the order in which feature configuration is loaded, with the latter sources overriding
the former if overlap in features occurs:

1. Context-specific feature files: <code>config/features/**/*.yml</code>
2. Main feature file: <code>config/features.yml</code>
3. Context-specific local feature file overrides: <code>config/features/**/*.local.yml</code>
4. Main local feature file override: <code>config/features.local.yml</code>
5. Environment variable overrides
6. Redis overrides

Rails Initializer
-----------------

Here is the content of the generated initializer [with `redis` client gem added] (<code>config/initializers/abstract_feature_branch.rb</code>), which contains instructions on how to customize via [dependency injection](http://en.wikipedia.org/wiki/Dependency_injection):

>     # Storage system for features (other than YAML/Env-Vars). Right now, only Redis and ConnectionPool are supported.
>     # AbstractFeatureBranch.feature_store = Redis.new
>
>     # Storage can be a Redis ConnectionPool instance
>     # AbstractFeatureBranch.feature_store = ConnectionPool.new { Redis.new }
>
>     # The following example line works with Heroku Redis To Go while still operating on local Redis for local development
>     # AbstractFeatureBranch.feature_store = Redis.new(:url => ENV['REDISTOGO_URL'])
>
>     # Enable live fetching of feature configuration from storage system, to update features without app/server restart.
>     # false by default to only load features on app/server start for faster performance (requires restart on change)
>     AbstractFeatureBranch.feature_store_live_fetching = false
>
>     # Application root where config/features.yml or config/features/ is found
>     AbstractFeatureBranch.application_root = Rails.root
>
>     # Application environment (e.g. "development", "staging" or "production")
>     AbstractFeatureBranch.application_environment = Rails.env.to_s
>
>     # Abstract Feature Branch logger
>     AbstractFeatureBranch.logger = Rails.logger
>
>     # Cache feature files once read or re-read them at runtime on every use (helps development).
>     # Defaults to true if environment not specified, except for development, which defaults to false.
>     AbstractFeatureBranch.cacheable = {
>       :development => false,
>       :test => true,
>       :staging => true,
>       :production => true
>     }
>
>     # Pre-load application features to improve performance of first web-page hit
>     AbstractFeatureBranch.load_application_features unless Rails.env.development?

Rake Task
---------

Abstract Feature Branch comes with a rake task to beautify feature files that have grown unorganized by sorting features
by name and getting rid of extra empty lines. It does so per section, without affecting the order of the sections
themselves.

For example, here is content before and after beautification.

Before:

>     defaults: &defaults
>
>
>       gallery: true
>
>       carousel: true
>
>       third_party_integration: false
>       caching: true
>
>     development:
>       <<: *defaults
>
>     test:
>       <<: *defaults
>
>       caching: false
>
>     staging:
>       <<: *defaults
>       third_party_integration: true
>       caching: true
>
>     production:
>       <<: *defaults
>       third_party_integration: false
>
>       caching: false

After:

>     defaults: &defaults
>       caching: true
>       carousel: true
>       gallery: true
>       third_party_integration: false
>
>     development:
>       <<: *defaults
>
>     test:
>       <<: *defaults
>       caching: false
>
>     staging:
>       <<: *defaults
>       caching: true
>       third_party_integration: true
>
>     production:
>       <<: *defaults
>       caching: false
>       third_party_integration: false

This is very useful in bigger applications that have scores of features since it allows a developer to quickly scan
for alphabetical sorted feature names. Although file find is an alternative solution, having tidy organized feature
names can help increase overall team productivity in the long term.

For Rails application use, the rake task is generated under <code>lib/tasks/abstract_feature_branch.rake</code>.

For Ruby application general use, here is the content of the rake task:

>     require 'abstract_feature_branch'
>     namespace :abstract_feature_branch do
>
>       desc "Beautify YAML of specified feature file via file_path argument or all feature files when no argument specified (config/features.yml, config/features.local.yml, and config/features/**/*.yml) by sorting features by name and eliminating extra empty lines"
>       task :beautify_files, :file_path do |_, args|
>         AbstractFeatureBranch::FileBeautifier.process(args[:file_path])
>       end
>
>     end

The rake task may be invoked in a number of ways:
- <code>rake abstract_feature_branch:beautify_files</code> beautifies all feature files under [application_root]/config
- <code>rake abstract_feature_branch:beautify_files[file_path]</code> beautifies a single feature file
- <code>rake abstract_feature_branch:beautify_files[directory_path]</code> beautifies all feature files under directory path recursively

Note that the beautifier ignores comments at the top, but deletes entire line comments in the middle of a YAML file, so
after invoking the rake task, **verify** that your feature file contents are to your satisfaction before committing the
task changes.

Feature Branches vs Branch by Abstraction
-----------------------------------------

Although feature branches and branching by abstraction are similar, there are different situations that recommend each approach.

Feature branching leverages your version control software (VCS) to create a branch that is independent of your main branch.  Once you write your feature, you integrate it with the rest of your code base. Feature branching is ideal for developing features that can be completed within the one or two iterations.  But it can become cumbersome with larger features due to the fact your code is isolated and quickly falls out of sync with your main branch.  You will have to regularly rebase with your main branch or devote substantial time to resolving merge conflicts.

Branching by abstraction, on the other hand, is ideal for substantial features, i.e. ones which take many iterations to complete.  This approach to branching takes place outside of your VCS.  Instead, you build your feature, but wrap the code inside configurable flags.  These configuration flags will allow for different behavior, depending on the runtime environment.  For example, a feature would be set to "on" when your app runs in development mode, but "off" when running in "production" mode.  This approach avoids the pain of constantly rebasing or resolving a myriad of merge conflicts when you do attempt to integrate your feature into the larger app.

Contributing to abstract_feature_branch
---------------------------------------

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Committers
---------------------------------------
* [Andy Maleh (Author)](https://github.com/AndyObtiva)

Contributors
---------------------------------------
* [Mark Moschel](https://github.com/mmosche2)

Copyright
---------------------------------------

Copyright (c) 2012-2023 Andy Maleh. See [LICENSE.txt](LICENSE.txt) for
further details.
