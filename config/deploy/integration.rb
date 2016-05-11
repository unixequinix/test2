set :branch, "jake"
set :rails_env, "integration"

# Default value for :log_level is :debug
set :log_level, :info

# Link certification folder
set :linked_dirs, fetch(:linked_dirs) + %w(certs)

# Server settings and naming
server "integration.glownet.com", user: "ubuntu", roles: %w(web app db)

# Security
set :default_run_options, pty: true

# SSH
set :ssh_options, forward_agent: true, auth_methods: %w(publickey)
