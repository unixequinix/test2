FactoryGirl.define do
  factory :pack_catalog_item do
    pack
    catalog_item
    sequence(:amount)
  end
end
