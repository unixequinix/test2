class Transactions::Credit::BalanceUpdater < Transactions::Base
  FEES = %w[initial_fee topup_fee refund_fee gtag_return_fee gtag_deposit_fee].freeze
  TRIGGERS = %w[sale topup refund record_credit sale_refund replacement_topup replacement_refund] + FEES

  queue_as :medium_low

  def perform(atts)
    Gtag.find(atts[:gtag_id]).recalculate_balance

    return unless atts[:customer_tag_uid] == atts[:operator_tag_uid]
    event = Event.find(atts[:event_id])
    transaction = Transaction.find(atts[:transaction_id])
    Alert.propagate(event, transaction, "has the same operator and customer UIDs", :medium)
  end
end
