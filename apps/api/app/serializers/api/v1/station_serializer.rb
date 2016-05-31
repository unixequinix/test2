class Api::V1::StationSerializer < Api::V1::BaseSerializer
  attributes :id, :type, :name

  def attributes(*args)
    hash = super
    hash[:catalog] = catalog if type == "box_office"
    hash[:products] = products if type == "point_of_sales"
    hash[:top_up_credits] = top_up_credits if
      type == "top_up_refund" || type == "hospitality_top_up"
    hash[:entitlements] = entitlements if type == "access_control"
    hash
  end

  def type
    object.category
  end

  def catalog
    object.station_catalog_items.map do |ci|
      { catalogable_id: ci.catalog_item.catalogable_id,
        catalogable_type: ci.catalog_item.catalogable_type.downcase,
        price: ci.price.round(2) }
    end
  end

  def products
    object.station_products.map do |sp|
      { product_id: sp.product_id,
        price: sp.price.round(2) }
    end
  end

  def top_up_credits
    object.topup_credits.map do |c|
      { amount: c.amount,
        price: (c.amount * c.credit.value).to_f.round(2) }
    end
  end

  def entitlements
    { in: object.access_control_gates.where(direction: "1").pluck(:access_id),
      out: object.access_control_gates.where(direction: "-1").pluck(:access_id) }
  end
end
