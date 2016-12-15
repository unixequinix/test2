Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

ruby '2.3.1'
source 'https://rubygems.org'

gem 'rails', '4.2.6'
gem 'sprockets-rails', '2.3.3'

# Database
gem 'pg', '~> 0.18.1'
gem 'activerecord-import', '~> 0.11.0'
gem 'active_record_bulk_insert'
gem 'nilify_blanks', '~>1.2.1'
gem 'oj'
gem 'oj_mimic_json'
gem 'deep_cloneable', '~> 2.2.1'

# Assets
gem 'jquery-rails', '~> 4.0.3'
gem 'jquery-ui-rails', '~> 4.2.0'
gem 'sass-rails', '~> 5.0.3'
gem 'uglifier', '~> 2.7.1'
gem 'slim', '~> 3.0.3'
gem 'simple_form', '~> 3.1.0'
gem 'paperclip', '~> 4.3.6'
gem 'aws-sdk-v1'
gem 'aws-sdk', '~> 2'
gem 'best_in_place', '~> 3.0.1'

# Authentication
gem 'devise', '~> 4.2'
gem 'omniauth', '~> 1.3', '>= 1.3.1'
gem 'omniauth-facebook', '~> 4.0'
gem 'omniauth-twitter', '~> 1.2', '>= 1.2.1'
gem "omniauth-google-oauth2"

# Design
gem 'bourbon', '~> 4.2.2'
gem 'neat', '~> 1.7.2'
gem 'font-awesome-rails', '~> 4.5.0.1'

# APIs
gem 'jbuilder', '~> 2.2.13'
gem 'active_model_serializers', git: 'https://github.com/rails-api/active_model_serializers.git'
gem 'rack-cors', require: 'rack/cors'
gem 'eventbrite', git: "https://github.com/envoy/eventbrite"

# Turbolinks
gem 'turbolinks', '~> 2.5.3'

# SEO
gem 'metamagic', '~> 3.1.7'
gem 'friendly_id', '~> 5.1.0'

# Logic
gem 'aasm', '~> 4.1.0'

# CSV
gem 'roo', '~> 2.0.0beta1'

# Navigation
gem 'gretel', '~> 3.0.8'
gem 'kaminari', '~>0.16.3'

# Search
gem 'ransack', '~> 1.6.6'

# Decorators
gem 'draper', '~> 2.0'

# Form normalizers
gem 'country_select', '~> 2.2.0'
gem 'phony_rails', '~> 0.12.8'
gem 'tinymce-rails'

# Payments
gem 'activemerchant', '~> 1.60'

# Flags
gem 'flag_shih_tzu', '~>0.3.13'

# Lists
gem 'acts_as_list'

# Asyncronous mailer
gem 'sinatra', require: false
gem 'sidekiq', '~> 4.0.1'
gem 'sidekiq-failures'

# Cron tasks
gem 'whenever', '~> 0.9.4', require: false

# Internationalization
gem 'globalize', '~> 5.0.1'
gem 'i18n-globals', '~> 0.0.4'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.1', group: :doc

# PDF Generation
gem 'wicked_pdf'

# Validations
gem 'rfc-822'
gem 'iban-tools', '~> 1.1'
gem 'iso-swift', '~> 0.0.2'

gem 'figaro', '~> 1.1', '>= 1.1.1'

group :development do
  gem 'foreman', '~> 0.78.0'
  gem 'bullet', '~> 4.14.4' # Help to kill N+1 queries and unused eager loading
  gem 'rails-erd', '~> 1.4.4' # Entity-relationship diagrams (ERD)
  gem 'railroady', '~> 1.4.1' # Controller diagrams (ERD)
  gem 'quiet_assets', '~> 1.1.0'
  gem 'hirb', '~> 0.7.3' #  Improve ripl(irb)'s default inspect output
  gem 'ruby-progressbar'
  gem 'capistrano'
  gem 'capistrano-rails', '~> 1.1.3'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-sidekiq', '~> 0.5.3'
  gem 'capistrano-faster-assets', '~> 1.0'
  gem 'annotate'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 4.0.5'
  gem 'better_errors', '~> 2.1.1'
  gem 'binding_of_caller', '~> 0.7.2' # extra features for better_errors
  gem 'meta_request', '~> 0.3.4' # for rails_panel chrome extension
  gem 'spring', '~> 1.3.5' # App preloader. https://github.com/rails/spring
  gem 'rspec-rails', '~> 3.2.1'
  gem 'rspec-mocks'
  gem 'rspec-activemodel-mocks'
  gem 'awesome_print', require:'ap'
  gem 'i18n-tasks', '~> 0.9.5'

  gem 'guard'
  gem 'guard-rubocop', require: false
  gem 'guard-rspec', '~> 4.5.0', require: false
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard', '~> 1.6.1'
  gem 'terminal-notifier'
end

group :development, :test, :integration do
  gem 'pry-rails'
  gem 'factory_girl_rails', '~> 4.5.0'
end

group :development, :test, :staging do
  gem 'faker', '~> 1.4.3'
  gem 'rubocop', require: false # Code quality https://github.com/bbatsov/rubocop
  gem 'rubocop-checkstyle_formatter', require: false
end

group :test do
  gem 'capybara', '~> 2.5.0'
  gem 'capybara-slow_finder_errors'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'launchy'
  gem 'shoulda-matchers', '~> 2.8.0', require: false
  gem 'database_cleaner', '~> 1.4.1'
  gem 'rspec-sidekiq'
  gem 'simplecov', '~> 0.10.0', require: false
  gem 'codecov', require: false
end

group :production, :staging, :demo, :refunds do
  gem 'dalli', '~> 2.7.4' # Memcached
  gem 'therubyracer'
end

group :production do
  gem 'newrelic_rpm'
end
