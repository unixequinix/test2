class Pokes::BalanceUpdater < Pokes::Base
  FEES = %w[initial_fee topup_fee refund_fee gtag_return_fee gtag_deposit_fee].freeze
  TRIGGERS = %w[sale topup refund record_credit sale_refund replacement_topup replacement_refund] + FEES

  def perform(t)
    t.gtag.recalculate_balance
    t.customer.update(initial_topup_fee_paid: true) if t.action.eql?("initial_fee")

    return unless t.customer_tag_uid == t.operator_tag_uid
    Alert.propagate(t.event, t, "has the same operator and customer UIDs", :medium)
  end
end
