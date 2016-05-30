
require "rails_helper"

RSpec.describe EventCreator, type: :domain_logic do
  describe "new instance of EventCreator" do
    it "should initialize the params and event attributes" do
      event_creator = EventCreator.new(
        name: "test", location: "test",
        start_date: Date.yesterday, end_date: Time.zone.today,
        description: "test", support_email: "test@test.com",
        features: "ticketing"
      )
      expect(event_creator.instance_variable_get(:@params)).not_to be_nil
      expect(event_creator.instance_variable_get(:@event)).not_to be_nil
    end
  end

  describe "save method" do
    it "should persist the event object in the db" do
      Seeder::SeedLoader.create_stations
      event_creator = EventCreator.new(
        name: "test", location: "test",
        start_date: Date.yesterday, end_date: Time.zone.today,
        description: "test", support_email: "test@test.com",
        currency: "GBP", host_country: "GB", features: "ticketing"
      )
      event_creator.save
      expect(event_creator.event.id).not_to be_nil
    end
  end
end
