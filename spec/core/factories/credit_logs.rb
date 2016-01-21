# == Schema Information
#
# Table name: credit_logs
#
#  id                        :integer          not null, primary key
#  transaction_type          :string
#  amount                    :decimal(8, 2)    not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_event_profile_id :integer
#

FactoryGirl.define do
  factory :credit_log do
    amount "9.99"
    customer_event_profile
    transaction_type { CreditLog::TRANSACTION_TYPES.sample }
  end
end
