class Pokes::Order < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[order_redeemed].freeze

  def perform(t)
    item = t.order_item
    Alert.propagate(t.event, t, "has no order attached") && return unless item

    if item.redeemed?
      Alert.propagate(t.event, item.order, "has been redeemed twice")
    else
      item.update!(redeemed: true)
      t.update(order: item.order)
      item.order.customer.touch
    end

    atts = { action: "order_redeemed", order_id: t.order_id }

    item = t.order_item&.catalog_item
    atts.merge!(extract_catalog_item_info(item)) if item

    create_poke(extract_atts(t, atts))
  end
end
