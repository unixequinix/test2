# == Schema Information
#
# Table name: refunds
#
#  id              :integer          not null, primary key
#  customer_id     :integer          not null
#  gtag_id         :integer          not null
#  bank_account_id :integer          not null
#  aasm_state      :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :refund do
    aasm_state 'created'
    gtag
    customer
    bank_account
  end
end
