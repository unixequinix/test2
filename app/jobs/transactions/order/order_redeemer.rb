class Transactions::Order::OrderRedeemer < Transactions::Base
  TRIGGERS = %w[order_redeemed].freeze

  def perform(atts)
    customer = Event.find(atts[:event_id]).customers.find(atts[:customer_id])
    customer.order_items.find_by(counter: atts[:order_item_counter]).update!(redeemed: true)
    customer.touch
  end
end
