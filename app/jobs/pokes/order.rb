class Pokes::Order < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[order_redeemed].freeze

  def perform(t)
    atts = { action: "order_redeemed", order_id: t.order_id }

    item = t.order.order_items.find_by(counter: t.order_item_counter)&.catalog_item
    atts.merge!(extract_catalog_item_info(item)) if item

    create_poke(extract_atts(t, atts))
  end
end
