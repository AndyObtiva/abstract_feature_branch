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

Setup
-----

In Rails 3.x:

1. Add 'abstract_feature_branch' gem to Gemfile in Rails 3.x or
"config.gem 'absract_feature_branch'" to environment.rb in Rails 2.x
2. Configure config/features.yml in your Rails app directory as follows:

>     defaults: &defaults
>       features:
>         feature1: true
>         feature2: true
>         feature3: false
>     
>     development:
>       <<: *defaults
>     
>     test:
>       <<: *defaults
>     
>     staging:
>       <<: *defaults
>         feature2: false
>     
>     production:
>       <<: *defaults
>       features:
>         feature1: false
>         feature2: false

Notice how the feature "add_business_project" was configured as true (enabled) by default, but
overridden as false (disabled) in production. This is a recommended practice.
3. feature branch your logic as per this example:

>     feature_branch :feature1 do
>       # perform add business logic
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
>         Please submit a business idea for investors to look at.
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

Copyright (c) 2012 Annas "Andy" Maleh. See LICENSE.txt for
further details.

