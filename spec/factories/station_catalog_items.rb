FactoryGirl.define do
  factory :station_catalog_item do
    sequence(:price) { |n| n.to_f + 1 }
    catalog_item
    station
  end
end
