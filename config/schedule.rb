# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "log/cron.log"
job_type :rake, "bash -c 'source ~deploy/.rvm/environments/ruby-2.5.0 && cd /home/deploy/current/ && RAILS_ENV=:environment bundle exec rake :task --silent :output'"

every 5.minutes do
  runner "CronJobs.import_tickets"
end

every '00 02 17-19 8 *' do
  rake "glownet:wework_script"
end
