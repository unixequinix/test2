class Transactions::Credit::BalanceUpdater < Transactions::Base
  TRIGGERS = %w(sale topup refund fee record_credit sale_refund).freeze

  def perform(atts)
    gtag = if atts[:gtag_id]
             Gtag.find(atts[:gtag_id])
           else
             Event.find(atts[:event_id]).gtags.find_by(tag_uid: atts[:customer_tag_uid])
           end

    gtag.recalculate_balance
  end
end
