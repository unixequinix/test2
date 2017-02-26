FactoryGirl.define do
  factory :station_product do
    station
    product
    price 99
    sequence(:position)
  end
end
