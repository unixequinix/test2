require "spec_helper"

RSpec.describe Event, type: :model do
  subject { build(:event) }

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

  describe ".active?" do
    it "returns true if the event is launched, started or finished" do
      subject.state = "closed"
      expect(subject).not_to be_active
      subject.state = "created"
      expect(subject).not_to be_active

      subject.state = "launched"
      expect(subject).to be_active
      subject.state = "started"
      expect(subject).to be_active
      subject.state = "finished"
      expect(subject).to be_active
    end
  end
end
