Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source 'https://rubygems.org'
ruby '2.3.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end



gem 'rails', '~> 5.0.1' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'puma', '~> 3.0' # Use Puma as the app server
gem 'therubyracer', platforms: :ruby
gem 'turbolinks', '~> 5'
gem 'globalize', github: 'globalize/globalize'
gem 'figaro'
gem 'aws-sdk', '~> 2'

# Database
gem 'activerecord-import'
gem 'active_record_bulk_insert'
gem 'nilify_blanks'
gem 'oj'
gem 'oj_mimic_json'
gem 'deep_cloneable'
gem 'pg' # Use pg as the database for Active Record

# Assets
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'slim'
gem 'simple_form'
gem 'paperclip'
gem 'best_in_place'
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets

# Authentication
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem "omniauth-google-oauth2"

# Design
gem 'bourbon'
gem 'neat'
gem 'font-awesome-rails'

# APIs
gem 'jbuilder', '~> 2.5'
gem 'active_model_serializers', git: 'https://github.com/rails-api/active_model_serializers.git'
gem 'rack-cors', require: 'rack/cors'
gem 'eventbrite', git: "https://github.com/envoy/eventbrite"

# SEO
gem 'friendly_id'

# CSV
gem 'roo'

# Navigation
gem 'kaminari'
gem 'gretel', git: 'git@github.com:lassebunk/gretel.git'

# Search
gem 'ransack'

# Form normalizers
gem 'country_select'
gem 'phony_rails'
gem 'tinymce-rails'

# Payments
gem 'activemerchant'

# Asyncronous mailer
gem 'sinatra', github: 'sinatra/sinatra', require: false
gem 'sidekiq'
gem 'sidekiq-failures'

# Cron tasks
gem 'whenever', require: false

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', group: :doc

# PDF Generation
gem 'wicked_pdf'

# Validations
gem 'rfc-822'
gem 'iban-tools'
gem 'iso-swift'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'foreman'
  gem 'bullet' # Help to kill N+1 queries and unused eager loading
  gem 'rails-erd' # Entity-relationship diagrams (ERD)
  gem 'ruby-progressbar'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-sidekiq'
  gem 'capistrano-faster-assets'
  gem 'capistrano-rails-console'
  gem 'annotate'
end

group :development, :test do
  gem 'byebug', platform: :mri # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rspec-rails'
  gem 'rspec-mocks'
  gem 'rspec-activemodel-mocks'
  gem 'awesome_print', require:'ap'
  gem 'guard'
  gem 'guard-rubocop', require: false
  gem 'guard-rspec', require: false
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard'
  gem 'terminal-notifier'
end

group :development, :test, :integration do
  gem 'factory_girl_rails'
end

group :development, :test, :staging do
  gem 'faker'
  gem 'rubocop', require: false # Code quality https://github.com/bbatsov/rubocop
  gem 'rubocop-checkstyle_formatter', require: false
end

group :test do
  gem 'capybara'
  gem 'capybara-slow_finder_errors'
  gem 'selenium-webdriver'
  gem 'poltergeist' # A PhantomJS driver for Capybara
  gem 'rspec-sidekiq'
  gem 'simplecov', require: false
  gem 'codecov', require: false
end

group :production do
  gem 'newrelic_rpm'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
