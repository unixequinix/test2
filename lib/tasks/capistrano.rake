namespace :deploy do


  desc 'Runs rake stats:db:create'
  task stats_create: [:set_rails_env] do
    on fetch(:migration_servers) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'stats:db:create'
        end
      end
    end
  end

  desc 'Runs rake stats:db:migrate'
  task stats_migrate: [:set_rails_env] do
    on fetch(:migration_servers) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'stats:db:migrate'
        end
      end
    end
  end
end