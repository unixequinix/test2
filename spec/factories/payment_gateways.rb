FactoryGirl.define do
  factory :payment_gateway do
    event
    name "bank_account"
    fee 0
    minimum 0
    data JSON.parse('{}')
  end
end
