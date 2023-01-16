source 'http://rubygems.org'

gem 'deep_merge', '>= 1.0.0', '< 2.0.0', :require => false #avoid loading to use only if Rails is unavailable

group :development do
  gem 'jeweler', '~> 2.3.9'
  gem 'bundler', '>= 2.1.4'
  gem 'rspec', '2.14.1'
  gem 'rdoc', '5.1.0'
  gem 'psych', '3.3.4'
end

group :test do
  gem 'coveralls', '= 0.8.23', require: false
  gem 'simplecov', '~> 0.16.1', require: nil
  gem 'simplecov-lcov', '~> 0.7.0', require: nil
#   gem 'codeclimate-test-reporter', '0.4.7', :require => false
  gem 'redis', '~> 5.0.5', :require => false
  gem 'puts_debuggerer', '~> 0.13.5'
end
