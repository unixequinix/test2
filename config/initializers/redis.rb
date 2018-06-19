$reports = Redis::Namespace.new("reports_queries", redis: Redis.new(host: ENV['REDIS_HOST'] || 'localhost', port: 6379, db: Rails.env.test? ? 9 : 2))
