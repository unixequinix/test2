class Transactions::Credit::BalanceUpdater < Transactions::Base
  TRIGGERS = %w(sale topup refund fee record_credit sale_refund).freeze

  def perform(atts)
    Gtag.find(atts[:gtag_id]).recalculate_balance
  end
end
