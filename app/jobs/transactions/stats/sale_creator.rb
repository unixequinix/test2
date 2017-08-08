class Transactions::Stats::SaleCreator < Transactions::Base
  include StatsHelper

  TRIGGERS = %w[sale sale_refund].freeze

  queue_as :low

  def perform(atts)
    t = CreditTransaction.find(atts[:transaction_id])
    t_atts = extract_atts_from_transaction(t).merge(payment_method: "credits")

    t.sale_items.order(:id).each.with_index { |item, index| create_stat t_atts.merge(extract_atts_from_sale_item(item, index + 1)) }

    other_amount = t.other_amount_credits.to_f.abs
    return if other_amount.zero?

    o_atts = t_atts.merge(transaction_counter: 0, product_qty: 1, product_name: "Other Product", total: other_amount)
    create_stat(o_atts)
  end
end
