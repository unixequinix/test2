class Api::V1::StationSerializer < Api::V1::BaseSerializer
  attributes :id, :type, :name

  def attributes(*args)
    hash = super
    hash[:catalog] = catalog if type == "box_office"
    hash[:products] = products if type == "pos"
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

  def products
    object.station_products.map do |sp|
      { product_id: sp.product_id,
        price: sp.price }
    end
  end
end
