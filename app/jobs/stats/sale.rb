class Stats::Sale < Stats::Base
  include StatsHelper

  TRIGGERS = %w[sale sale_refund].freeze

  def perform(transaction_id)
    t = CreditTransaction.find(transaction_id)
    t_atts = extract_credit_atts(t.event.credit)

    t.sale_items.order(:id).map.with_index { |item, index| create_stat extract_atts(t, t_atts.merge(extract_atts_from_sale_item(item, index + 1))) }
  end
end
