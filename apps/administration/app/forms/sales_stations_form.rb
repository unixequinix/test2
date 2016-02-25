class SalesStationsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :station_id, Integer
  attribute :catalog_item_id, Integer
  attribute :price, Float

  validates_presence_of :station_id
  validates_presence_of :catalog_item_id
  validates_presence_of :price

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    StationCatalogItem.new(
      catalog_item_id: catalog_item_id,
      price: price,
      station_parameters_attributes: { station_id: station_id }
    )
  end
end
