class Sorters::FakeCatalogItem
  include ActiveModel::Model
  include Virtus.model

  attribute :product_name, String
  attribute :catalogable_type, String
  attribute :catalog_item_id, Integer
  attribute :total_amount, Integer
end
