class Api::V1::StationSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :hidden

  def id
    object.station_event_id
  end

  def attributes(*args)
    hash = super
    method(object.form).call(hash) if object.form
    hash
  end

  def type
    object.category
  end

  def accreditation(hash)
    hash[:catalog] = object.station_catalog_items.map do |ci|
      { catalog_item_id: ci.catalog_item_id, price: ci.price.round(2), hidden: ci.hidden? }
    end
  end

  def pos(hash)
    hash[:products] = object.station_products.map do |sp|
      { product_id: sp.product_id, price: sp.price.round(2), position: sp.position, hidden: sp.hidden? }
    end
  end

  def topup(hash)
    hash[:top_up_credits] = object.topup_credits.map do |c|
      { amount: c.amount, price: (c.amount * c.credit.value).to_f.round(2), hidden: c.hidden? }
    end
  end

  def access(hash)
    hash[:entitlements] = {
      in: object.access_control_gates.in.map { |g| { id: g.access_id, hidden: g.hidden? } },
      out: object.access_control_gates.out.map { |g| { id: g.access_id, hidden: g.hidden? } }
    }
  end
end
