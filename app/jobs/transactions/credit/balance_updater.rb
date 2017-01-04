class Transactions::Credit::BalanceUpdater < Transactions::Base
  TRIGGERS = %w(sale topup refund fee record_credit sale_refund).freeze

  def perform(atts)
    Gtag.find_by(event_id: atts[:event_id], id: atts[:gtag_id], activation_counter: atts[:activation_counter]).recalculate_balance
  end
end
