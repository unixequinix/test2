# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# custom
require 'capistrano/rails'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/passenger'
require 'capistrano/faster_assets'
require 'capistrano/sidekiq'
require 'capistrano/rails/console'
require 'whenever/capistrano'
require 'rollbar/capistrano3'
