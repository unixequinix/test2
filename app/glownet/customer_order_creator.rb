class CustomerOrderCreator
  def initialize(redeemed = false)
    @redeemed = redeemed
  end

  def save(order, payment_method, payment_gateway)
    order.order_items.each do |order_item|
      CustomerOrder.create(profile: order.profile,
                           amount: order_item.amount,
                           catalog_item: order_item.catalog_item,
                           origin: CustomerOrder::PURCHASE,
                           redeemed: @redeemed)
      Transactions::Base.new.portal_write(fields(order_item, payment_method, payment_gateway))
    end
  end

  # rubocop:disable Metrics/MethodLength
  def fields(order_item, payment_method, payment_gateway)
    event = order_item.order.profile.event_id
    station = Station.find_by(event: event, category: "customer_portal").id
    {
      event_id: order_item.order.profile.event_id,
      station_id: station,
      transaction_category: "money",
      transaction_origin: Transaction::ORIGINS[:portal],
      transaction_type: "portal_purchase",
      customer_tag_uid: order_item.order.profile.active_gtag&.tag_uid,
      catalogable_id: order_item.catalog_item.catalogable_id,
      catalogable_type: order_item.catalog_item.catalogable_type,
      items_amount: order_item.amount,
      price: order_item.total,
      payment_method: payment_method,
      payment_gateway: payment_gateway,
      profile_id: order_item.order.profile.id,
      status_code: 0,
      status_message: "OK"
    }
  end
end
