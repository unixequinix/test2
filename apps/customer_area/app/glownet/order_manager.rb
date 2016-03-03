class OrderManager
  def sanitize_order(current_order)
    if current_order.in_progress?
      order = current_customer_event_profile.orders.build
      current_order.order_items.each do |order_item|
        order.order_items << OrderItem.new(catalog_item_id: order_item.catalog_item.id,
                                           amount: order_item.amount, total: order_item.total)
      end
      order.generate_order_number!
      order.save
    else
      current_order
    end
  end
end
