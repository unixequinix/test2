require "rails_helper"

RSpec.describe Event, type: :model do
  subject { build(:event) }

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

  describe ".event_serie_id" do
    before do
      create(:event_serie, :with_events, associated_events: subject)
    end

    it "returns event_serie_id" do
      expect(subject.event_serie_id).not_to be_nil
    end
  end

  describe ".currency_symbol" do
    it "returns symbol" do
      expect(subject.currency_symbol).to be_a(String)
    end

    it "add errors if currency is blank" do
      subject.currency = nil
      expect(subject.currency_symbol).to be_nil
    end
  end
end
