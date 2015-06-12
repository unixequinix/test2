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
    amount '9.99'
    terminal { Faker::Lorem.word }
    transaction_type { Faker::Lorem.word }
    card_country { Faker::Lorem.word }
    response_code { Faker::Number.number(10) }
    authorization_code { Faker::Number.number(10) }
    currency { Faker::Lorem.word }
    merchant_code { Faker::Lorem.word }
    success true
    payment_type { Faker::Lorem.word }
    pait_at { Time.now }
  end
end
