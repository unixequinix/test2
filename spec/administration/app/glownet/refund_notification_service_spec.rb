require "rails_helper"

RSpec.describe RefundNotificationService, type: :service do
  describe "notify" do
    it "should notify the users that the claiming period has started" do
      event = build(:event, aasm_state: "claiming_started")
      cep = FactoryGirl.create(:customer_event_profile, event: event)
      FactoryGirl.create(:gtag_registration, customer_event_profile: cep)

      expect(RefundNotificationService.new.notify(event)).to eq(true)
    end
  end
end