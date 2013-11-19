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
   - Rails (~> 4.0.0 or ~> 3.0): Add the following to Gemfile <pre>gem 'abstract_feature_branch', '0.3.4'</pre>
   - Rails (~> 2.0): Add the following to config/environment.rb <pre>config.gem 'absract_feature_branch'</pre>
2. Generate config/features.yml in your Rails app directory by running <pre>rails g abstract_feature_branch:install</pre>

Here are the contents of the generated sample config/features.yml, which you can modify with your own features.

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

Instructions
------------

- declaratively feature branch logic to only run when feature1 is enabled:

>     feature_branch :feature1 do
>       # perform logic
>     end

- declaratively feature branch two paths of logic, one that runs when feature1 is enabled and one that runs when it is disabled:

>     feature_branch :feature1,
>                    :true => lambda {
>                      # perform logic
>                    },
>                    :false => lambda {
>                      # perform alternate logic
>                    }

- imperatively check if a feature is enabled or not:

>     if feature_enabled?(:feature1)
>       # perform logic
>     else
>       # perform alternate logic
>     end

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

- Once a feature has been released and switched on in production, and it has worked well for a while,
it is recommended that its feature branching code is plucked out of the code base to simplify the code
for better maintenance as the need is not longer there for feature branching at that point.

Release Notes
-------------

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

