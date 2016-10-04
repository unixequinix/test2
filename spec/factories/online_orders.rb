FactoryGirl.define do
  factory :online_order do
    customer_order
    counter { rand(1000) }
    redeemed { [true, false].sample }
  end
end
