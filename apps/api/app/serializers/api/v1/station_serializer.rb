class Api::V1::StationSerializer < Api::V1::BaseSerializer
  attributes :id, :type, :name

  def attributes(*args)
    hash = super
    hash[:catalog] = catalog if type == "box_office"
    hash
  end

  def type
    object.station_type.name
  end

  def catalog
    object.station_catalog_items.map do |ci|
      { catalogable_id: ci.catalog_item.catalogable_id,
        catalogable_type: ci.catalog_item.catalogable_type.downcase,
        price: ci.price }
    end
  end
end
