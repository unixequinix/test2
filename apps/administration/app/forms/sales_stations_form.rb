class SalesStationsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :station_catalog_items

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
    attributes.each do |attribute|
      StationCatalogItem.new(
        price: attribute[:price],
        catalog_item_id: attribute[:catalog_item_id],
        station_parameter_attributes: { station_id: attribute[:station_id] }
      )
    end
  end
end
