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

# 1.minute 1.day 1.week 1.month 1.year is also supported
every 10.minutes do
  runner "Event.try_to_end_refunds"
  runner "Event.try_to_open_refunds"
end

every 1.minute do
  runner "Event.reload_stats"
end

every 5.minutes do
  runner "Event.import_palco4_tickets"
end

every 10.minutes do
  rake "sidekiq:restart"
end
