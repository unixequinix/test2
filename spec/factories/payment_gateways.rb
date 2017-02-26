FactoryGirl.define do
  factory :payment_gateway do
    event
    gateway { %w(paypal stripe redsys).sample }
    data {}
  end
end
