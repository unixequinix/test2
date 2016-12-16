# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"
require "capistrano/rvm"
require "capistrano/bundler"
require "capistrano/rails"
require "capistrano/sidekiq" # Rails has to be above sidekiq for deploy purposes
require "capistrano/rails/assets"
require "whenever/capistrano"
require "capistrano/passenger"
require 'capistrano/rails/console'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
