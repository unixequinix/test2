class Transactions::Stats::FeeCreator < Transactions::Base
  include StatsHelper

  TRIGGERS = %w[gtag_return_fee gtag_deposit_fee initial_fee topup_fee].freeze

  queue_as :low

  def perform(atts)
    t = CreditTransaction.find(atts[:transaction_id])

    return if t.credits.to_f.zero?

    t_atts = extract_atts_from_transaction(t).merge(payment_method: "credits", transaction_counter: 0, total: t.credits.abs)
    create_stat(t_atts)
  end
end
