ActiveJob::Base.queue_adapter = :sidekiq
ActiveJob::Base.queue_adapter = :inline if Rails.env.test?
