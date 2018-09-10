require 'sidekiq/middleware/i18n'

url = ENV["JOB_WORKER_URL"] || "redis://localhost:6379"

Sidekiq.configure_server do |config|
  config.redis = { url: url, network_timeout: 5 }
  config.failures_default_mode = :exhausted
  config.failures_max_count = false
end

Sidekiq.configure_client do |config|
  config.redis = { url: url, network_timeout: 5 }
end

ActiveJob::Base.queue_adapter = :inline if Rails.env.test? || Rails.env.development?
