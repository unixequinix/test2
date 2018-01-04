module Transactions
  class Order::OrderRedeemer < Transactions::Base
    TRIGGERS = %w[order_redeemed].freeze

    queue_as :medium_low

    def perform(transaction, _atts = {})
      item = transaction.order_item
      Alert.propagate(transaction.event, item.order, "has been redeemed twice") && return if item.redeemed?

      item.update!(redeemed: true)
      item.order.customer.touch
    end
  end
end
