require 'rails_helper'

RSpec.describe Alert, type: :model do
  let(:event) { create(:event) }
  let(:alert) { create(:alert, event: event) }

  describe ".propagate" do
    let(:obj) { create(:gtag, event: event) }

    it "creates and alert for the event provided" do
      expect { Alert.propagate(event, obj, "test", :low) }.to change { event.reload.alerts.count }.by(1)
    end

    it "creates an alert only once for same subject and message" do
      alert = Alert.propagate(event, obj, "test")
      expect(Alert.propagate(event, obj, "test")).to eql(alert)
    end

    it "sets priority to high by default" do
      alert = Alert.propagate(event, obj, "test")
      expect(alert.priority).to eql("high")
    end
  end
end
