require 'sidekiq/middleware/i18n'

Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.secrets.redis_server, network_timeout: 5 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.secrets.redis_client, network_timeout: 5 }
end