require "spec_helper"

RSpec.describe EventCreator, type: :domain_logic do
  let(:creator) { EventCreator.new(name: "Glownet Event") }

  describe ".initialize" do
    it "should initialize the params and event attributes" do
      expect(creator.instance_variable_get(:@params)).not_to be_nil
      expect(creator.instance_variable_get(:@event)).not_to be_nil
    end
  end

  describe ".save" do
    it "should persist the event object in the db" do
      expect { creator.save }.to change(Event, :count).by(1)
    end

    it "creates the standard credit" do
      expect(creator.save.credit).not_to be_nil
    end

    it "creates the default user flags" do
      expect(creator.save.user_flags).not_to be_nil
    end

    describe "creates the station" do
      before(:each) { @event = creator.save }
      let(:customer_portal) { @event.stations.find_by(category: "customer_portal", group: "access") }

      it "cs accreditation" do
        station = @event.stations.find_by(category: "cs_accreditation", group: "event_management")
        expect(station).not_to be_nil
      end

      it "cs topup refund" do
        station = @event.stations.find_by(category: "cs_topup_refund", group: "event_management")
        expect(station).not_to be_nil
      end

      it "customer portal" do
        expect(customer_portal).not_to be_nil
      end

      it "customer portals credit" do
        credit = customer_portal.station_catalog_items.first.catalog_item
        expect(credit).to be_kind_of(Credit)
      end

      it "touchpoint" do
        station = @event.stations.find_by(category: "touchpoint", group: "touchpoint")
        expect(station).not_to be_nil
      end

      it "Gtag Recycler" do
        station = @event.stations.find_by(category: "gtag_recycler", group: "glownet")
        expect(station).not_to be_nil
      end

      it "Operator permissions" do
        station = @event.stations.find_by(category: "operator_permissions", group: "event_management")
        expect(station).not_to be_nil
      end
    end
  end
end
