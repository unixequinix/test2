class Payments::CustomerOrderBuilder
  def save(order)
    order.order_items.each do |order_item|
      CustomerOrder.create(
        customer_event_profile: order.customer_event_profile,
        preevent_product: order_item.preevent_product)
    end
  end
end
