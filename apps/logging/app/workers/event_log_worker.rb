class EventLogWorker
  include Sidekiq::Worker
  def perform(name, count)
    name.capitalize
    count + 1
  end
end