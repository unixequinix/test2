class Stats::Purchase < Stats::Base
  include StatsHelper

  # MoneyTransaction#topup actually does not exist, since online topups are called purchases. But in case it happens
  TRIGGERS = %w[box_office_purchase portal_purchase].freeze

  def perform(transaction_id)
    t = MoneyTransaction.find(transaction_id)
    atts = extract_money_atts(t, action: "purchase")
    item_atts = extract_catalog_item_info(t.catalog_item, atts)

    return create_stat(extract_atts(t, item_atts)) if t.catalog_item
    return unless t.order

    t.order.order_items.map.with_index do |item, index|
      item_atts = atts.merge(monetary_unit_price: item.total, monetary_total_price: item.total, line_counter: index + 1)
      item_atts.merge! extract_catalog_item_info(item.catalog_item, item_atts)
      create_stat(extract_atts(t, item_atts))
    end
  end
end
