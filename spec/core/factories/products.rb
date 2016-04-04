FactoryGirl.define do
  factory :product do
    event
    name { "Product #{rand(10_000)}" }
    description { "Description #{rand(10_000)}" }
    is_alcohol { [true, false].sample }
  end
end
