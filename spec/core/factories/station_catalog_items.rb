FactoryGirl.define do
  factory :station_catalog_item do
    price { rand(100.00) }
    catalog_item { build(:catalog_item, :with_access) }
  end
end
