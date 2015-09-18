# == Schema Information
#
# Table name: refunds
#
#  id                         :integer          not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  claim_id                   :integer
#  amount                     :decimal(8, 2)    not null
#  currency                   :string
#  message                    :string
#  operation_type             :string
#  gateway_transaction_number :string
#  payment_solution           :string
#  status                     :string
#

require 'rails_helper'

RSpec.describe Refund, type: :model do
  it { is_expected.to validate_presence_of(:claim) }
  it { is_expected.to validate_presence_of(:amount) }
  it "should set the data for the exportation" do
    refund = create(:refund)
    claim = refund.claim
    gtag = claim.gtag
    event = gtag.event_id
    expect(Refund.selected_data(event)).not_to eq(nil)
  end
end
