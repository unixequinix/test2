# == Schema Information
#
# Table name: payments
#
#  id                 :integer          not null, primary key
#  order_id           :integer          not null
#  amount             :decimal(8, 2)    not null
#  terminal           :string
#  transaction_type   :string
#  card_country       :string
#  response_code      :string
#  authorization_code :string
#  currency           :string
#  merchant_code      :string
#  success            :boolean
#  payment_type       :string
#  paid_at            :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :payment do
    amount "9.99"
terminal "MyString"
transaction_type "MyString"
card_country "MyString"
response_code "MyString"
authorization_code "MyString"
currency "MyString"
merchant_code "MyString"
success ""
payment_type "MyString"
pait_at "2015-04-28 11:49:59"
  end

end
