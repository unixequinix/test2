class Transactions::Order::OrderRedeemer < Transactions::Base
  TRIGGERS = %w[order_redeemed].freeze

  queue_as :medium_low

  def perform(atts)
    transaction = OrderTransaction.find(atts[:transaction_id])
    customer = transaction.event.customers.find(atts[:customer_id])
    item = customer.order_items.find_by(counter: atts[:order_item_counter])
    order = item.order

    Alert.propagate(transaction.event, order, "has been redeemed twice") && return if item.redeemed?

    item.update!(redeemed: true)
    customer.touch
  end
end
