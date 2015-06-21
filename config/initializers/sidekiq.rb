Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://pub-redis-10706.eu-west-1-1.1.ec2.garantiadata.com:10706' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://pub-redis-10706.eu-west-1-1.1.ec2.garantiadata.com:10706' }
end