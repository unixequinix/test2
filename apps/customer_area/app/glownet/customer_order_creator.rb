class CustomerOrderCreator
  def save(order)
    order.order_items.each do |order_item|
      customer_order = CustomerOrder.create(
        customer_event_profile: order.customer_event_profile,
        amount: order_item.amount,
        catalog_item: order_item.catalog_item,
        origin: CustomerOrder::PURCHASE)
      OnlineOrder.create(
        redeemed: false,
        customer_order: customer_order
      )
    end
  end
end
