FactoryGirl.define do
  factory :pack_catalog_item do
    pack
    catalog_item
    amount { rand(1..8) }
  end
end
