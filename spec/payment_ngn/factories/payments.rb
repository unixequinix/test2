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
    order
    terminal { "word #{rand(100)}" }
    transaction_type { "word #{rand(100)}" }
    card_country { "word #{rand(100)}" }
    response_code { rand(10) }
    authorization_code { rand(10) }
    currency { "word #{rand(100)}" }
    merchant_code { "word #{rand(100)}" }
    success true
    payment_type { "word #{rand(100)}" }
    paid_at { Time.now }
  end
end
