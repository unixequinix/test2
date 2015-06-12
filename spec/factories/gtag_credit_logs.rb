# == Schema Information
#
# Table name: gtag_credit_logs
#
#  id         :integer          not null, primary key
#  gtag_id    :integer          not null
#  amount     :decimal(8, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :gtag_credit_log do
    amount '9.99'
    gtag
  end
end
