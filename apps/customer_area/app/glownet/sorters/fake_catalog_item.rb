class Sorters::FakeCatalogItem
  include ActiveModel::Model
  include Virtus.model

  attribute :product_name, String
  attribute :catalogable_type, String
  attribute :catalogable_id, Integer
  attribute :catalog_item_id, Integer
  attribute :total_amount, Integer
  attribute :value, Decimal


  def eql?(other)
    @catalog_item_id == other.catalog_item_id
  end

end
