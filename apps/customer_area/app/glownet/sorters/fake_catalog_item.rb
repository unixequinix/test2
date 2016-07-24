class Sorters::FakeCatalogItem
  include ActiveModel::Model
  include Virtus.model

  attribute :product_name, String
  attribute :catalogable_type, String
  attribute :catalogable_id, Integer
  attribute :catalog_item_id, Integer
  attribute :total_amount, Decimal
  attribute :value, Decimal

  def eql?(other)
    @catalog_item_id == other.catalog_item_id
  end

  def catalogable
    klass = catalogable_type.constantize
    klass.find(catalogable_id)
  end

  def catalog_item
    CatalogItem.find(catalog_item_id)
  end
end
