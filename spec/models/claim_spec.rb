require "rails_helper"

RSpec.describe Claim, type: :model do
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:total) }
  it { is_expected.to validate_presence_of(:aasm_state) }

  describe "generate_claim_number!" do
    it "should create a valid number for a claim" do
      claim = create(:claim)
      day = Date.today.strftime('%y%m%d')
      claim.generate_claim_number!

      expect(claim.number).to start_with(day)
      expect(claim.number).to match(/^[a-f0-9]*$/)
    end
  end

  describe "complete_claim" do
    it "should store the time when a claim is completed" do
      claim = create(:claim)
      time_before = claim.completed_at.to_i
      claim.start_claim
      claim.complete
      time_after = claim.completed_at.to_i

      expect(time_after).to be > time_before
    end
  end

  describe "Claim.selected_data" do
    it "should prepare the rows with the default columns and the extra columns
      for a csv exportation" do
        refund = create(:refund)
        gtag = create(:gtag)
        customer = create(:customer)
        customer_event_profile = create(:customer_event_profile, customer: customer)
        claim = create(:claim,
          aasm_state: :completed,
          customer_event_profile: customer_event_profile,
          gtag: gtag,
          refund: refund,
          service_type: "bank_account"
        )
        parameter = create(:parameter, name: "iban", category: "claim", group: "bank_account")
        claim_parameter = create(:claim_parameter, claim: claim, parameter: parameter)

        claims, headers, extra_columns = Claim.selected_data(:completed)

        expect(claims.size).to eq(1)
        expect(headers).to eq(["iban"])
        expect(extra_columns.size).to eq(1)
    end
  end

end