FactoryBot.define do
  factory :pack_catalog_item do
    pack
    catalog_item
    amount { 1 }
  end
end
