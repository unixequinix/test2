module Transactions
  class Order::OrderRedeemer < Transactions::Base
    TRIGGERS = %w[order_redeemed].freeze

    queue_as :medium_low

    def perform(transaction, atts = {})
      customer = transaction.event.customers.find(atts[:customer_id])
      item = customer.order_items.find_by(counter: transaction.order_item_counter)
      order = item.order

      Alert.propagate(transaction.event, order, "has been redeemed twice") && return if item.redeemed?

      item.update!(redeemed: true)
      customer.touch
    end
  end
end
