source 'https://rubygems.org'

gem 'rails', '4.2.1'

# Database
gem 'pg', '~> 0.18.1'
gem 'schema_plus', '~> 2.0.0.pre12'
gem 'paranoia', '~> 2.0'
gem 'activerecord-import', '~> 0.8.0'
gem 'nilify_blanks', '~>1.2.1'

# Assets
gem 'jquery-rails', '~> 4.0.3'
gem 'sass-rails', '~> 5.0.3'
gem 'uglifier', '~> 2.7.1'
gem 'slim', '~> 3.0.3'
gem 'simple_form', '~> 3.1.0'
gem 'paperclip', '~> 4.2.2'
gem 'aws-sdk-v1'
gem 'aws-sdk', '~> 2'

# Authentication
gem 'devise', '~> 3.4.1'
gem 'devise-i18n', '~> 0.12.0'

# Design
gem 'bourbon', '~> 4.2.2'
gem 'neat', '~> 1.7.2'
gem 'font-awesome-rails', '~> 4.3.0.0'

# JSON APIs
gem 'jbuilder', '~> 2.2.13'
gem 'active_model_serializers', '~> 0.9.3'
gem 'rack-cors', require: 'rack/cors'

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

# Form normalizers
gem 'iban-tools', '~>1.0.0'
gem 'iso-swift', '~>0.0.2'
gem 'country_select', '~> 2.2.0'
gem 'phony_rails', '~> 0.12.8'

# Flags
gem 'flag_shih_tzu', '~>0.3.13'

# Architectural
gem 'virtus', '~> 1.0.5'
gem 'reform', '~> 1.2.6'

# Asyncronous mailer
gem 'sinatra', require: false
gem 'sidekiq', '~> 3.4.1'

# Cron tasks
gem 'whenever', '~> 0.9.4', require: false

# Internationalization
gem 'globalize', '~> 5.0.1'
gem 'i18n-globals', git: 'https://github.com/sebastianzillessen/i18n-globals.git'

group :development do
  gem 'foreman', '~> 0.78.0'
  gem 'capistrano'
  gem 'capistrano-rails', '~> 1.1.3'
  gem 'capistrano-rbenv', '~> 2.0.3'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'annotate', '~> 2.6.8'
  gem 'bullet', '~> 4.14.4' # Help to kill N+1 queries and unused eager loading
  gem 'rails-erd', '~> 1.3.1' # Entity-relationship diagrams (ERD)
  gem 'quiet_assets', '~> 1.1.0'
  gem 'hirb', '~> 0.7.3' #  Improve ripl(irb)'s default inspect output
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.1', group: :doc
end

group :development, :darwin do
  gem 'rb-fsevent'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 4.0.5'
  gem 'pry-rails', '~> 0.3.4'
  gem 'better_errors', '~> 2.1.1'
  gem 'binding_of_caller', '~> 0.7.2' # extra features for better_errors
  gem 'meta_request', '~> 0.3.4' # for rails_panel chrome extension
  gem 'spring', '~> 1.3.5' # App preloader. https://github.com/rails/spring
  gem 'rspec-rails', '~> 3.2.1'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'guard-rspec', '~> 4.5.0', require: false
  gem 'spring-commands-rspec', '~> 1.0.4'
end

group :development, :test, :staging do
  gem 'faker', '~> 1.4.3'
  gem 'rubocop', '~>0.30.1', require: false # Code quality https://github.com/bbatsov/rubocop
  gem 'simplecov', '~> 0.10.0', require: false # Code quality https://github.com/colszowka/simplecov
end

group :test do
  gem 'capybara', '2.4.4'
  gem 'shoulda-matchers', '~> 2.8.0', require: false
  gem 'database_cleaner', '~> 1.4.1'
end

group :production, :staging, :demo, :refunds do
  gem 'therubyracer', '~> 0.12.2', platforms: :ruby
  gem 'dalli', '~> 2.7.4' # Memcached
  gem 'newrelic_rpm', '~> 3.12.0.288'
end
