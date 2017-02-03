namespace :glownet do
  desc "Creates a basic event"
  task sample_event: :environment do
    event = SampleEvent.run
    puts "-------------------------------------------"
    puts "Event name: '#{event.name}'"
    puts "https://#{Rails.env}.glownet.com/admins/events/#{event.slug}"
  end
end
