class Stats::Sale < Stats::Base
  include StatsHelper

  TRIGGERS = %w[sale sale_refund].freeze

  def perform(transaction_id)
    t = CreditTransaction.find(transaction_id)
    t_atts = extract_credit_atts(t.event.credit)

    t.sale_items.order(:id).each.with_index { |item, index| create_stat extract_atts(t, t_atts.merge(extract_atts_from_sale_item(item, index + 1))) }

    other_amount = t.other_amount_credits.to_f
    return if other_amount.zero?

    qty = t.action.eql?("sale") ? 1 : -1

    o_atts = t_atts.merge(line_counter: 0, sale_item_quantity: qty, product_name: "Other Product", sale_item_unit_price: other_amount, sale_item_total_price: other_amount) # rubocop:disable Metrics/LineLength
    create_stat(extract_atts(t, o_atts))
  end
end
