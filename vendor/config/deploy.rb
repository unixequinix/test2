set :application, "arepa"
set :repo_url, "git@github.com:Gl0wnet/web-core.git"

# While migrations looks like a concern of the database layer, migrations are strictly related to the framework. https://github.com/capistrano/rails
set :migration_role, :app

# Default branch is HEAD
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/deploy"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, false # sidekiq demands this https://github.com/seuros/capistrano-sidekiq/wiki

# Default value for :linked_files is []
append :linked_files, "config/application.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rvm_ruby_version, '2.5.1'

set :sidekiq_config, File.join(current_path, 'config', 'sidekiq.yml')

set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

set :rollbar_token, "3bc66b29685d47b9934a72438c532838"
set :rollbar_env, -> { fetch(:stage) }
set :rollbar_role, :app

load "lib/tasks/capistrano.rake"
