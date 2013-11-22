Abstract Feature Branch
=======================

abstract_feature_branch is a Rails gem that enables developers to easily branch by
abstraction as per this pattern: http://paulhammant.com/blog/branch_by_abstraction.html

It gives ability to wrap blocks of code with an abstract feature branch name, and then
specify which features to be switched on or off in a configuration file.

The goal is to build out future features with full integration into the codebase, thus
ensuring no delay in integration in the future, while releasing currently done features
at the same time. Developers then disable future features until they are ready to be
switched on in production, but do enable them in staging and locally.

This gives developers the added benefit of being able to switch a feature off after
release should big problems arise for a high risk feature.

Requirements
------------
- Ruby ~> 2.0.0, ~> 1.9 or ~> 1.8.7
- Rails ~> 4.0.0, ~> 3.0 or ~> 2.0

Setup
-----

1. Configure Rubygem
   - Rails (~> 4.0.0 or ~> 3.0): Add the following to Gemfile <pre>gem 'abstract_feature_branch', '0.5.0'</pre>
   - Rails (~> 2.0): Add the following to config/environment.rb <pre>config.gem 'absract_feature_branch', :version => '0.5.0'</pre>
2. Generate <code>config/features.yml</code> and <code>config/features.local.yml</code> in your Rails app directory by running <pre>rails g abstract_feature_branch:install</pre>

Instructions
------------

<code>config/features.yml</code> contains the main configuration for the application features.

<code>config/features.local.yml</code> contains local overrides for the configuration, ignored by git, thus useful for temporary
local feature switching for development/testing/troubleshooting purposes.

Here are the contents of the generated sample config/features.yml, which you can modify with your own features, each
enabled (true) or disabled (false) per environment (e.g. production).

>     defaults: &defaults
>       feature1: true
>       feature2: true
>       feature3: false
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

Note that <code>feature_branch</code> returns nil and does not execute the block if the feature is disabled or non-existent.

- Declaratively feature branch two paths of logic, one that runs when feature1 is enabled and one that runs when it is disabled:

>     feature_branch :feature1,
>                    :true => lambda {
>                      # perform logic
>                    },
>                    :false => lambda {
>                      # perform alternate logic
>                    }

Note that <code>feature_branch</code> executes the false branch if the feature is non-existent.

- Imperatively check if a feature is enabled or not:

>     if feature_enabled?(:feature1)
>       # perform logic
>     else
>       # perform alternate logic
>     end

Note that <code>feature_enabled?</code> returns false if the feature is disabled and nil if the feature is non-existent (practically the same effect, but nil can sometimes be useful to detect if a feature is referenced).

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

- In Rails 4 and 3.1+ with the asset pipeline, wrap newly added CSS or JavaScript using .erb format. Example (renamed projects.css.scss to projects.css.scss.erb and wrapped CSS with an abstract feature branch block):

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

- Once a feature has been released and switched on in production, and it has worked well for a while,
it is recommended that its feature branching code is plucked out of the code base to simplify the code
for better maintenance as the need is not longer there for feature branching at that point.

- When working on a new feature locally that the developer does not want others on the team to see yet, the feature
can be enabled in <code>config/features.local.yml</code> only as it is git ignored, and disabled in <code>config/features.yml</code>

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

To remove environment variable override, you may run:

>     unset ABSTRACT_FEATURE_BRANCH_FEATURE1
>     rails s

This can be done more easily via <code>config/features.local.yml</code> mentioned above. However, environment variable overrides are
implemented to support overriding feature configuration for a Heroku deployed application more easily.

Heroku
------

Environment variable overrides can be extremely helpful on Heroku as they allow developers to enable/disable features
at runtime without a redeploy.

Examples:

Enabling a new feature without a redeploy:
<pre>heroku config:add ABSTRACT_FEATURE_BRANCH_FEATURE3=true -a heroku_application_name</pre>

Disabling a buggy recently deployed feature without a redeploy:
<pre>heroku config:add ABSTRACT_FEATURE_BRANCH_FEATURE2=false -a heroku_application_name</pre>

Removing an environment variable override:
<pre>heroku config:remove ABSTRACT_FEATURE_BRANCH_FEATURE2 -a heroku_application_name</pre>

Recommendation:

It is recommended that you use environment variable overrides on Heroku only as an emergency or temporary measure.
Afterward, make the change officially in config/features.yml, deploy, and remove the environment variable override for the long term.

Gotcha with abstract feature branching in CSS and JS files:

If you've used abstract feature branching in CSS or JS files via ERB, setting environment variable overrides won't
affect them as you need asset recompilation in addition to it, which can only be triggered by changing a CSS or JS
file and redeploying on Heroku (hint: even if it's just a minor change to force it). In any case, environment variable
overrides have been recommended above as an emergency or temporary measure. If there is a need to rely on environment
variable overrides to alter the style or JavaScript behavior of a page back and forth without a redeploy, one solution
is to do additional abstract feature branching in HTML templates (e.g. ERB or HAML templates) to link to different
CSS classes or invoke different JavaScript methods per branch of HTML for example.

Release Notes
-------------

Version 0.5.0:
- Added support for local configuration feature ignored by git + some performance optimizations via configuration caching and better algorithms.

Version 0.4.0:
- Added support for overwriting feature configuration with environment variable overrides. Very useful on Heroku to quickly enable/disable features without a redeploy.

Version 0.3.6:
- Fixed feature_branch issue with invalid feature name, preventing block execution and returning nil instead

Version 0.3.5:
- Fixed issue with generator not allowing consuming client app to start Rails server successfully

Version 0.3.4:
- Added abstract_feature_branch:install generator to easily get started with a sample config/features.yml

Version 0.3.3:
- Removed version from README title

Version 0.3.2:
- Added AbstractFeatureBranch.features to delay YAML load until Rails.root has been established

Version 0.3.1:
- Removed dependency on the rails_config gem

Version 0.3.0:
- Simplified features.yml requirement to have a features header under each environment
- Moved feature storage from Settings object to AbstractFeatureBranch::FEATURES

Version 0.2.0:
- Support an "else" block to execute when a feature is off (via :true and :false lambda arguments)
- Support ability to check if a feature is enabled or not (via feature_enabled?)

Upcoming
--------

- Support the option of having multiple features.yml files, one per environment, as opposed to one for all environments
- Support general Ruby (non-Rails) use
- Support contexts of features to group features, once they grow beyond a certain size, in separate files, one per context
- Add rake task to reorder feature entries in feature.yml alphabetically

Contributing to abstract_feature_branch
---------------------------------------

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------------------------------------

Copyright (c) 2013 Annas "Andy" Maleh. See LICENSE.txt for
further details.

