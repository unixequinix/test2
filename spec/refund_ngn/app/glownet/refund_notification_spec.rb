require "rails_helper"

RSpec.describe RefundNotification, type: :domain_logic do
  describe "notify" do
    it "should notify the users that the claiming period has started" do
      event = create(:event, aasm_state: "finished")
      cep = create(:profile, event: event)
      create(:credential_assignment_g_a, profile: cep)
      expect(RefundNotification.new.notify(event)).to eq(true)
    end
  end
end
