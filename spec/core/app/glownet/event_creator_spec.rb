require "rails_helper"

RSpec.describe EventCreator, type: :domain_logic do
  let(:new_event) do
    EventCreator.new(
      name: "Glownet Event", location: "Amsterdam",
      start_date: Date.yesterday, end_date: Time.zone.today,
      description: "An awesome event", support_email: "events@glownet.com",
      currency: "EUR", host_country: "AMS", features: 1
    )
  end

  describe ".initialize" do
    it "should initialize the params and event attributes" do
      expect(new_event.instance_variable_get(:@params)).not_to be_nil
      expect(new_event.instance_variable_get(:@event)).not_to be_nil
    end
  end

  describe ".save" do
    it "should persist the event object in the db" do
      expect { new_event.save }.to change(Event, :count).by(1)
    end
  end

  describe ".standard_credit" do
    let(:event) { new_event.save }

    it "adds the standard credit to the event" do
      expect(event.credits.standard).not_to be_nil
    end
  end

  describe ".customer_portal_station" do
    let(:event) { new_event.save }
    let(:customer_portal) { event.stations.find_by(category: "customer_portal", group: "access") }

    it "creates customer portal station" do
      expect(customer_portal).not_to be_nil
    end

    it "adds the standard credit to the station" do
      credit = customer_portal.station_catalog_items.first.catalog_item.catalogable
      expect(credit).to be_kind_of(Credit)
      expect(credit.standard).to be_truthy
    end
  end

  describe ".customer_service_stations" do
    let(:event) { new_event.save }

    it "creates the cs accreditation station" do
      station = event.stations.find_by(category: "cs_accreditation", group: "event_management")
      expect(station).not_to be_nil
    end

    it "creates the cs gtag balance fix station" do
      station = event.stations.find_by(category: "cs_gtag_balance_fix", group: "event_management")
      expect(station).not_to be_nil
    end

    it "creates the cs topup refund station" do
      station = event.stations.find_by(category: "cs_topup_refund", group: "event_management")
      expect(station).not_to be_nil
    end
  end

  describe ".tocuhpoint_station" do
    let(:event) { new_event.save }
    
    it "creates the touchpoint station" do
      station = event.stations.find_by(category: "touchpoint", group: "touchpoint")
      expect(station).not_to be_nil
    end
  end
end
