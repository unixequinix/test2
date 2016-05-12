class CustomerOrderCreator
  def save(order, payment_method, payment_gateway)
    order.order_items.each do |order_item|
      customer_order = CustomerOrder.create(profile: order.profile,
                                            amount: order_item.amount,
                                            catalog_item: order_item.catalog_item,
                                            origin: CustomerOrder::PURCHASE)
      OnlineOrder.create(redeemed: false, customer_order: customer_order)
      create_money_transaction(order_item, payment_method, payment_gateway)
    end
  end

  def create_money_transaction(order_item, payment_method, payment_gateway)
    # TODO: check
    Operations::Base.new.portal_write(fields(order_item, payment_method, payment_gateway))
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def fields(order_item, payment_method, payment_gateway)
    station = Station.joins(:station_type)
                     .find_by(event: order_item.order.profile.event_id,
                              station_types: { name: "customer_portal" }).id
    {
      event_id: order_item.order.profile.event_id,
      station_id: station,
      transaction_category: "money",
      transaction_origin: "customer_portal",
      transaction_type: "portal_purchase",
      customer_tag_uid: order_item.order.profile.active_gtag_assignment.credentiable.tag_uid,
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
