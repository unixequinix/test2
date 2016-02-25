FactoryGirl.define do
  factory :station_catalog_item do
    price { rand(100.00) }
    station
    product_catalog_item
  end
end
