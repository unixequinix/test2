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

FactoryGirl.define do
  factory :refund do
    claim
    amount 9.98
    currency "dummy"
    message "dummy"
    operation_type "dummy"
    gateway_transaction_number "dummy"
    payment_solution "dummy"
    status "dummy"
  end
end