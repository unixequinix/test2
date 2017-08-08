Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source 'https://rubygems.org'
ruby '2.4.1'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gem 'rails', '~> 5.1.2' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'therubyracer', platforms: :ruby
gem 'turbolinks', '~> 5'
gem 'figaro'
gem 'aws-sdk', '~> 2'
gem 'redis', '~> 3.0' # Use Redis adapter to run Action Cable in production
gem 'cookies_eu'
gem 'http-accept' # parsers for dealing with HTTP Accept, Accept-Language...
# gem 'bcrypt', '~> 3.1.7' # Use ActiveModel has_secure_password

# Database
gem 'activerecord-import'
gem 'active_record_bulk_insert'
gem 'nilify_blanks'
gem 'oj'
gem 'oj_mimic_json'
gem 'deep_cloneable'
gem 'pg' # Use pg as the database for Active Record
gem 'json', '~> 1.8.5' # TODO: remove after deploy of JSON v3

# Assets
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'slim-rails'
gem 'simple_form'
gem 'paperclip'
gem 'best_in_place', github: 'bernat/best_in_place'
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets

# Authentication
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
gem 'pundit'

# Design
gem 'font-awesome-rails'
gem 'chartkick'
gem 'groupdate'

# APIs
gem 'jbuilder', '~> 2.5'
gem 'active_model_serializers'
gem 'rack-cors'
gem 'eventbrite', github: 'envoy/eventbrite'
gem 'rack-attack'

# SEO
gem 'friendly_id'

# CSV
gem 'roo'

# Navigation
gem 'kaminari'

# Search
gem 'ransack', github: 'activerecord-hackery/ransack'

# Form normalizers
gem 'country_select'
gem 'phony_rails'
gem 'tinymce-rails'

# Payments
gem 'activemerchant', github: "aspgems/active_merchant"

# Asyncronous
gem 'sinatra', github: 'sinatra/sinatra', require: false
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'whenever', :require => false

# PDF Generation
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Validations
gem 'rfc-822'
gem 'iban-tools'
gem 'iso-swift', github: 'hugolantaume/iso-swift'
gem 'bsb'

# Rollbar
gem 'rollbar'

group :development do
  gem 'rails-erd' # Entity-relationship diagrams (ERD)
  gem 'ruby-progressbar'
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'capistrano-faster-assets', '~> 1.0'
  gem 'capistrano-rails-console', require: false
  gem 'capistrano-sidekiq', github: 'seuros/capistrano-sidekiq'
  gem 'xray-rails'
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
  gem 'puma', '~> 3.0' # Use Puma as the app server
  gem 'factory_girl_rails'
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

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
