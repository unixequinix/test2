# config valid only for current version of Capistrano
lock "3.4.0"

set :application, "glownet_web"
set :repo_url, "git@gitlab.dev.glownet.com:acidtango/glownet_web.git"
set :bundle_without, [:darwin, :development, :test]
set :deploy_to, "~/glownet_web"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(config/database.yml config/secrets.yml config/newrelic.yml)

# Default value for linked_dirs is []
set :linked_dirs, %w(log store tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :sidekiq_default_hooks, true
set :sidekiq_pid, File.join(shared_path, "tmp", "pids", "sidekiq.pid")
set :sidekiq_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage)))
set :sidekiq_log, File.join(shared_path, "log", "sidekiq.log")
set :sidekiq_config, File.join(shared_path, 'config', "sidekiq.yml")
# set :sidekiq_options, nil
# set :sidekiq_require, nil
# set :sidekiq_tag, nil
# set :sidekiq_config, nil
# set :sidekiq_queue, %w(default mailer)
# set :sidekiq_timeout, 10
# set :sidekiq_role, :app
# set :sidekiq_processes, 1
# set :sidekiq_options_per_process, nil
# set :sidekiq_concurrency, 1

set :pty, false

set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do
  desc "Restart database"
  task :restart_db do
    on roles(:app), in: :sequence, wait: 5 do
      execute :rake, "db:migrate"
    end
  end

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join("tmp/restart.txt")
      # execute "service apache2 restart"
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :publishing, :restart
end
