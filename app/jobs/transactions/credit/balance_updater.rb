class Transactions::Credit::BalanceUpdater < Transactions::Base
  TRIGGERS = %w[sale topup refund fee record_credit sale_refund].freeze

  def perform(atts)
    event = Event.find(atts[:event_id])
    params = atts[:gtag_id] ? { id: atts[:gtag_id] } : { tag_uid: atts[:customer_tag_uid] }
    gtag = event.gtags.find_by(params)
    transaction = event.transactions.find_by(id: atts[:transaction_id])
    transaction&.update!(gtag: gtag) if atts[:gtag_id].nil?
    gtag.recalculate_balance

    return unless atts[:customer_tag_uid] == atts[:operator_tag_uid]
    Alert.propagate(event, "has the same operator and customer UIDs", :medium, transaction)
  end
end
