class Pokes::Order < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[order_redeemed].freeze

  def perform(transaction)
    item = transaction.order_item
    Alert.propagate(transaction.event, transaction, "has no order attached") && return unless item

    if item.redeemed?
      Alert.propagate(transaction.event, item.order, "has been redeemed twice")
    else
      item.update!(redeemed: true)
      transaction.update(order: item.order)
      item.order.customer.touch
    end

    atts = { action: "order_redeemed", order_id: transaction.order_id }

    item = transaction.order_item&.catalog_item
    atts.merge!(extract_catalog_item_info(item)) if item

    create_poke(extract_atts(transaction, atts))
  end
end
