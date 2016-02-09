require "rails_helper"

RSpec.describe RefundNotification, type: :domain_logic do
  describe "notify" do
    it "should notify the users that the claiming period has started" do
      event = build(:event, aasm_state: "claiming_started")

      cep = create(:customer_event_profile, event: event)
      create(:credential_assignment_g_a, customer_event_profile: cep)
      expect(RefundNotification.new.notify(event)).to eq(true)
    end
  end
end
