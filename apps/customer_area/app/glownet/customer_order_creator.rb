class CustomerOrderCreator
  def save(order)
    order.order_items.each do |order_item|
      order_item.amount.times do
        CustomerOrder.create(
          customer_event_profile: order.customer_event_profile,
          catalog_item: order_item.catalog_item)
      end
    end
  end
end
