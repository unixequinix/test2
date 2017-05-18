class Transactions::Order::OrderRedeemer < Transactions::Base
  TRIGGERS = %w[order_redeemed].freeze

  def perform(atts)
    event = Event.find(atts[:event_id])
    customer = event.customers.find(atts[:customer_id])
    item = customer.order_items.find_by(counter: atts[:order_item_counter])
    return if item.redeemed?

    item.update!(redeemed: true)
    event.transactions.find(atts[:transaction_id]).update!(order: item.order)
    customer.touch
  end
end
