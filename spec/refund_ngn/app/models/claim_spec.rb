# == Schema Information
#
# Table name: claims
#
#  id                        :integer          not null, primary key
#  number                    :string           not null
#  aasm_state                :string           not null
#  completed_at              :datetime
#  total                     :decimal(8, 2)    not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  gtag_id                   :integer
#  service_type              :string
#  fee                       :decimal(8, 2)    default(0.0)
#  minimum                   :decimal(8, 2)    default(0.0)
#  customer_event_profile_id :integer
#

require "rails_helper"

RSpec.describe Claim, type: :model do
  let(:event) { build(:event) }
  let(:claim) { create(:claim) }

  describe ".complete!" do
    before { claim.start_claim! }

    it "sets the completed_at time to now" do
      expect(claim.completed_at).to be_nil
      claim.complete!
      expect(claim.completed_at).not_to be_nil
    end
  end

  describe ".selected_data" do
    before :each do
      ClaimParameter.destroy_all
      Refund.destroy_all
      Claim.destroy_all
      Seeder::SeedLoader.load_param(event, category: "refund")
    end

    it "prepares the rows with the default columns and the extra columns for a csv exportation" do
      gtag = create(:gtag, event: event)
      customer = create(:customer, event: event)
      profile = create(:customer_event_profile, customer: customer, event: event)
      claim = create(:claim,
                     aasm_state: :completed,
                     customer_event_profile: profile,
                     gtag: gtag,
                     service_type: "bank_account")
      parameter = Parameter.find_by(name: "iban", category: "claim", group: "bank_account")
      create(:claim_parameter, claim: claim, parameter: parameter)
      create(:refund, claim: claim)
      claims, headers, extra_columns = Claim.selected_data(:completed, gtag.event)
      expect(claims.size).to eq(1)
      expect(headers).to eq(["iban"])
      expect(extra_columns.size).to eq(1)
    end
  end
end
