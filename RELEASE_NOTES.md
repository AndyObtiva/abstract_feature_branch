Release Notes
-------------

Version 0.9.0:
- Added configuration support for feature cacheability

Version 0.9.0:
- Added support for runtime read of feature files in development to ease local testing (trading off performance)

Version 0.8.0:
- Added rake task for beautifying feature files, sorting feature names within environment sections and eliminating extra empty lines. Added support for externalized logger.

Version 0.7.1:
- Fixed undefined method issue with using <code>AbstractFeatureBranch.load_application_features</code> to improve first use performance

Version 0.7.0:
- Added support for general Ruby use (without Rails) by externalizing AbstractFeatureBranch.application_root and AbstractFeatureBranch.application_environment. Added initializer to optionally configure them. Supported case-insensitive feature names.

Version 0.6.1 - 0.6.4:
- Fixed issues including making feature configuration files optional (in case one wants to get rid of <code>features.local.yml</code> or even <code>features.yml</code>)

Version 0.6.0:
- Added a context generator and support for reading feature configuration from context files <code>config/features/**/*.yml</code> and <code>config/features/**/*.local.yml</code>

Version 0.5.0:
- Added support for local configuration feature ignored by git + some performance optimizations via configuration caching and better algorithms.

Version 0.4.0:
- Added support for overwriting feature configuration with environment variable overrides. Very useful on Heroku to quickly enable/disable features without a redeploy.

Version 0.3.6:
- Fixed feature_branch issue with invalid feature name, preventing block execution and returning nil instead

Version 0.3.5:
- Fixed issue with generator not allowing consuming client app to start Rails server successfully

Version 0.3.4:
- Added <code>abstract_feature_branch:install</code> generator to easily get started with a sample <code>config/features.yml</code>

Version 0.3.3:
- Removed version from README title

Version 0.3.2:
- Added <code>AbstractFeatureBranch.features</code> to delay YAML load until <code>Rails.root</code> has been established

Version 0.3.1:
- Removed dependency on the rails_config gem

Version 0.3.0:
- Simplified <code>features.yml</code> requirement to have a features header under each environment
- Moved feature storage from Settings object to <code>AbstractFeatureBranch::FEATURES</code>

Version 0.2.0:
- Support an "else" block to execute when a feature is off (via <code>:true</code> and <code>:false</code> lambda arguments)
- Support ability to check if a feature is enabled or not (via <code>feature_enabled?</code>)