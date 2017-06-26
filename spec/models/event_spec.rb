require "rails_helper"

RSpec.describe Event, type: :model do
  subject { build(:event) }

  describe ".resolve_time!" do
    before do
      @good_device = create(:device)
      @bad_device = create(:device)
      subject.update(start_date: 1.hour.ago, end_date: Time.current + 1.hour)
      subject.devices = [@good_device, @bad_device]

      created_at = Time.current.to_formatted_s(:transactions)
      create_list(:credit_transaction, 3, device_created_at: created_at, event: subject, action: "sale", device_uid: @good_device.mac)

      created_at = (Time.current - 10.hours).to_formatted_s(:transactions)
      create(:credit_transaction, device_created_at: created_at, event: subject, action: "sale", device_uid: @bad_device.mac)
    end

    it "it should call resolve_time on bad devices only" do
      devices = subject.devices
      expect(subject).to receive(:devices).once.and_return(devices)
      expect(devices).to receive(:where).with(mac: [@bad_device.mac]).once.and_return([@bad_device])

      registrations = subject.device_registrations
      bad_registration = @bad_device.device_registrations.find_by(event: subject)
      expect(subject).to receive(:device_registrations).once.and_return(registrations)
      expect(registrations).to receive(:where).with(device: [@bad_device]).once.and_return([bad_registration])
      subject.resolve_time!
    end
  end

  describe ".valid_app_version?" do
    before { subject.app_version = "1.0.0.0" }

    it "returns true if version is higher" do
      expect(subject.valid_app_version?("1.0.0.1")).to be_truthy
    end

    it "returns true if version matches" do
      expect(subject.valid_app_version?("1.0.0.0")).to be_truthy
    end

    it "returns false if version is lower" do
      expect(subject.valid_app_version?("0.9.9.9")).to be_falsey
    end

    it "handles 3 digit versions with valid app version" do
      expect(subject.valid_app_version?("1.0.1")).to be_truthy
    end

    it "handles 3 digit versions with invalid app version" do
      expect(subject.valid_app_version?("0.9.1")).to be_falsey
    end

    it "handles pre-release versions" do
      expect(subject.valid_app_version?("1.0.1-beta")).to be_truthy
    end

    it "handles pre-release of the same version" do
      expect(subject.valid_app_version?("1.0.0.0-DEBUG")).to be_truthy
    end

    it "always returns true if the app_version is all" do
      subject.app_version = "all"
      expect(subject.valid_app_version?("notaversion")).to be_truthy
      expect(subject.valid_app_version?(nil)).to be_truthy
      expect(subject.valid_app_version?([])).to be_truthy
    end
  end

  describe ".eventbrite?" do
    it "returns true if the event has eventbrite_token and eventbrite_event" do
      expect(subject).not_to be_eventbrite
      subject.eventbrite_token = "test"
      expect(subject).not_to be_eventbrite
      subject.eventbrite_event = "test"
      expect(subject).to be_eventbrite
    end
  end

  describe ".credit_price" do
    it "returns the event credit value" do
      subject.save
      subject.create_credit!(value: 1, name: "CR")
      expect(subject.credit_price).to eq(subject.credit.value)
    end
  end

  describe ".event_serie_id" do
    before do
      create(:event_serie, :with_events, associated_events: subject)
    end

    it "returns event_serie_id" do
      expect(subject.event_serie_id).not_to be_nil
    end
  end
end
