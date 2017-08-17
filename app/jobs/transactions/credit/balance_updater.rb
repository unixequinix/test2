class Transactions::Credit::BalanceUpdater < Transactions::Base
  TRIGGERS = %w[sale topup refund fee record_credit sale_refund].freeze

  queue_as :low

  def perform(atts)
    Gtag.find(atts[:gtag_id]).recalculate_balance

    return unless atts[:customer_tag_uid] == atts[:operator_tag_uid]
    event = Event.find(atts[:event_id])
    transaction = Transaction.find(atts[:transaction_id])
    Alert.propagate(event, "has the same operator and customer UIDs", :medium, transaction)
  end
end
