if Rails.application.secrets.redis_reports_client.present?
  $reports = Redis::Namespace.new("reports_queries", redis: Redis.new(host: Rails.application.secrets.redis_host, port: 6379, db: Rails.env.test? ? 9 : 2)) 
end