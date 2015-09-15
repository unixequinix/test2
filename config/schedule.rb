env :PATH, ENV['PATH']

set :output, 'log/cron.log'
set :environment, ENV['RAILS_ENV']

every :reboot do
  rake 'sidekiq:restart'
end
