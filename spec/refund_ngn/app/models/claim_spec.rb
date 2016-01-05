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
  describe "Claim.selected_data" do
    it "should prepare the rows with the default columns and the extra columns for a csv exportation" do
      gtag = create(:gtag)
      event = gtag.event
      customer = create(:customer, event: event)
      customer_event_profile = create(:customer_event_profile, customer: customer, event: event)
      claim = create(:claim,
                     aasm_state: :completed,
                     customer_event_profile: customer_event_profile,
                     gtag: gtag,
                     service_type: "bank_account"
                    )
      refund = create(:refund, claim: claim)
      parameter = Parameter.find_by(name: "iban", category: "claim", group: "bank_account")
      claim_parameter = create(:claim_parameter, claim: claim, parameter: parameter)
      claims, headers, extra_columns = Claim.selected_data(:completed, gtag.event)
      expect(claims.size).to eq(1)
      expect(headers).to eq(["iban"])
      expect(extra_columns.size).to eq(1)
    end
  end
end
