class Transactions::Credit::BalanceUpdater < Transactions::Base
  TRIGGERS = %w( sale topup refund fee record_credit sale_refund ).freeze

  def perform(atts)
    gtag = Gtag.find_by(event_id: atts[:event_id], id: atts[:gtag_id])
    gtag = Gtag.find_by(tag_uid: atts[:customer_tag_uid].to_s.scan(/.{1,2}/).reverse.join) unless gtag

    gtag.recalculate_balance

  end
end
