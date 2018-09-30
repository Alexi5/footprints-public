source 'https://rubygems.org'

gem 'rails', '4.0.2'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails', '~> 3.1.0'
gem 'turbolinks', '~> 2.2.1'
gem "rake", '~> 10.1.1'
gem "will_paginate", '~> 3.0.5'
gem "safe_yaml", '~> 1.0.1'
gem "jquery-ui-rails", '~> 4.2.0'
gem "nilify_blanks", '~> 1.0.3'
gem "highrise", '~> 3.1.5'
gem "mail", '~> 2.5.4'
gem "omniauth-google-oauth2", '~> 0.2.2'
gem "edn", '~> 1.0.2'
gem "httparty", '~> 0.13.0'
gem "american_date"
gem 'mysql2', '~> 0.3.18'
gem 'activerecord-native_db_types_override'

gem 'stockroom', git: 'https://github.com/ryanzverner/stockroom-ruby-client.git'

group :doc do
  gem 'sdoc', require: false
end

group :test, :development do
  gem "sqlite3", '~> 1.3.9'
  gem "rspec-rails", '~> 2.14.1'
  gem "teaspoon"
  gem "teaspoon-jasmine"
  gem "awesome_print"
  gem "better_errors", '1.1.0'
  gem "net-ssh", '2.8.0'
  gem "capistrano", :require => false
  gem "capistrano-rails", "~> 1.4", require: false
  gem "capistrano-rvm", require: false
  gem 'capistrano3-unicorn', require: false
end

gem 'simplecov', :require => false, :group => :test

group :production do
  gem 'unicorn', '~> 4.8.2'
end

gem "guard", "~> 2.14"

gem "guard-rspec", "~> 4.3"
