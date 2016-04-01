FactoryGirl.define do
  factory :product do
    name { "Product #{rand(10_000)}" }
    is_alcohol { [true, false].sample }
  end
end
