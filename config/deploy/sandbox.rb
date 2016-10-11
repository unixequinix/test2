set :branch, "development"
set :rails_env, "sandbox"

# Default value for :log_level is :debug
set :log_level, :info

# Link certification folder
set :linked_dirs, fetch(:linked_dirs) + %w(certs)

# server settings
server "sandbox.glownet.com", user: "ubuntu", roles: %w(web app db)
