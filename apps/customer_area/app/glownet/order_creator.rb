class OrderCreator
  def self.autotopup_order(profile, event)
    order = Order.new(profile: profile)
    order.generate_order_number!
    catalog_item = event.credits.standard.catalog_item
    order.order_items << OrderItem.new(
      catalog_item_id: catalog_item.id,
      amount: 1,
      total: 0.01
    )
    order.save
    order
  end
end