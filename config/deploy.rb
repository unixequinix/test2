set :application, "glownet_web"
set :repo_url, "git@github.com:Gl0wnet/web-core.git"
set :bundle_without, [:darwin, :development, :test]
set :deploy_to, "~/glownet_web"

# Default value for :pty is false
# There is a known bug that prevents sidekiq from starting when pty is true on Capistrano 3
set :pty, false
set :ssh_options, forward_agent: true, auth_methods: %w(publickey)

# Default value for :linked_files is []
set :linked_files, %w(config/application.yml)
set :figaro_yml_remote_path, File.join(shared_path, "config", "application.yml")

# Default value for linked_dirs is []
set :linked_dirs, %w(log store tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)

# sidekiq options here better to separate per production
set :sidekiq_default_hooks, true
set :sidekiq_pid, File.join(shared_path, "tmp", "pids", "sidekiq.pid")
set :sidekiq_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage)))
set :sidekiq_log, File.join(shared_path, "log", "sidekiq.log")
set :sidekiq_concurrency, 1
set :sidekiq_queue, [:default, :mailers]

set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :glownet do
  desc "Create or reset admin account"
  task :create_admin do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "glownet:create_admin"
        end
      end
    end
  end
end

namespace :deploy do
  desc "Runs rake db:seed"
  task seed: [:set_rails_env] do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:seed"
        end
      end
    end
  end

  after :migrate, :seed

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join("tmp/restart.txt")
    end
  end

  after :publishing, :restart
end
