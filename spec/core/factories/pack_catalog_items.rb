FactoryGirl.define do
  factory :pack_catalog_item do
    pack
    catalog_item
    amount { rand(0..1) }
  end
end
