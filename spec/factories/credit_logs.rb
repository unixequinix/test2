# == Schema Information
#
# Table name: credit_logs
#
#  id               :integer          not null, primary key
#  customer_id      :integer          not null
#  transaction_type :string
#  amount           :decimal(8, 2)    not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do
  factory :credit_log do
    amount '9.99'
    transaction_type { CreditLog::TRANSACTION_TYPES.sample }
    customer
  end
end
