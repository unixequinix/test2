FactoryBot.define do
  factory :catalog_item do
    event
    type { "CatalogItem" }
    sequence(:name) { |n| "Item #{n}" }
  end
end
