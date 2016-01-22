require "rails_helper"

RSpec.describe RefundNotification, type: :domain_logic do
  describe "notify" do
    it "should notify the users that the claiming period has started" do
      event = build(:event, aasm_state: "claiming_started")
      FactoryGirl.create(:customer_event_profile, event: event)
      expect(RefundNotification.new.notify(event)).to eq(true)
    end
  end
end
