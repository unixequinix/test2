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

  desc "Create or reset admin account"
  task :sample_event do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "glownet:sample_event"
        end
      end
    end
  end
end
