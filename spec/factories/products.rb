FactoryGirl.define do
  factory :product do
    station
    sequence(:name) { |i| "Product #{i}" }
    price 99
    sequence(:position)
  end
end
