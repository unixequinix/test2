module Transactions
  class Credit::BalanceUpdater < Transactions::Base
    FEES = %w[initial_fee topup_fee refund_fee gtag_return_fee gtag_deposit_fee].freeze
    TRIGGERS = %w[sale topup refund record_credit sale_refund replacement_topup replacement_refund] + FEES

    queue_as :medium_low

    def perform(transaction, _atts = {})
      transaction.gtag.recalculate_balance
      transaction.customer.update(initial_topup_fee_paid: true) if transaction.action.eql?("initial_fee")

      return unless transaction.customer_tag_uid == transaction.operator_tag_uid
      Alert.propagate(transaction.event, transaction, "has the same operator and customer UIDs", :medium)
    end
  end
end
