namespace :sidekiq do
  desc 'Start sidekiq'
  task start: :environment do
    system "bundle exec sidekiq -e #{Rails.env} -d -L 'log/sidekiq.log'"
  end
end
