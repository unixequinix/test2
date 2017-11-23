class Stats::Order < Stats::Base
  include StatsHelper

  TRIGGERS = %w[order_redeemed].freeze

  def perform(transaction_id)
    t = OrderTransaction.find(transaction_id)

    atts = { action: "order_redeemed", order_id: t.order_id }

    item = t.order.order_items.find_by(counter: t.order_item_counter)&.catalog_item
    atts.merge!(extract_catalog_item_info(item)) if item

    create_stat(extract_atts(t, atts))
  end
end