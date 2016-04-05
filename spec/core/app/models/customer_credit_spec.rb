# == Schema Information
#
# Table name: customer_credits
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer          not null
#  transaction_origin        :string           not null
#  payment_method            :string           not null
#  amount                    :decimal(8, 2)    default(1.0), not null
#  refundable_amount         :decimal(8, 2)    default(1.0), not null
#  final_balance             :decimal(8, 2)    default(1.0), not null
#  final_refundable_balance  :decimal(8, 2)    default(1.0), not null
#  credit_value              :decimal(8, 2)    default(1.0), not null
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  created_in_origin_at      :datetime
#

require "rails_helper"

RSpec.describe CustomerCredit, type: :model do
  describe ".calculate_balances" do
    it "should set the balances of the customer credit right before it is saved " \
       "(amount == refundable_amount)" do
      customer_credit = CustomerCredit.new(customer_event_profile_id: 1,
                                           amount: 2,
                                           refundable_amount: 2,
                                           payment_method: "none",
                                           transaction_origin: "ticket_purchase")
      expect(customer_credit.final_balance).to eq(0)
      expect(customer_credit.final_refundable_balance).to eq(0)

      customer_credit.save
      expect(customer_credit.final_balance).to eq(2)
      expect(customer_credit.final_refundable_balance).to eq(2)

      customer_credit = CustomerCredit.create(customer_event_profile_id: 1,
                                              amount: 5,
                                              refundable_amount: 2,
                                              payment_method: "none",
                                              transaction_origin: "ticket_purchase")
      expect(customer_credit.final_balance).to eq(7)
      expect(customer_credit.final_refundable_balance).to eq(4)
    end
  end
end
