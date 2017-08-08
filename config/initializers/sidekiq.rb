require 'sidekiq/middleware/i18n'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379", network_timeout: 5 }
  config.failures_default_mode = :exhausted
  config.failures_max_count = false
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:6379", network_timeout: 5 }
end

if Rails.env.development? || Rails.env.test?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end