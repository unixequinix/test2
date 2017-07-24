class Transactions::Stats::TopupCreator < Transactions::Base
  include StatsHelper

  TRIGGERS = %w[onsite_topup onsite_refund].freeze

  def perform(atts)
    t = MoneyTransaction.find(atts[:transaction_id])

    action = t.action.gsub("onsite_", "")
    t_atts = extract_atts_from_transaction(t).merge(payment_method: t.payment_method, action: action, transaction_counter: 0, total: t.price.abs)

    create_stat(t_atts)
  end
end
