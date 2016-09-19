class Operations::Order::OrderRedeemer < Operations::Base
  TRIGGERS = %w( record_purchase ).freeze

  def perform(atts)
    gtag = Gtag.find_by(tag_uid: atts[:customer_tag_uid], event_id: atts[:event_id], activation_counter: atts[:activation_counter])
    profile = gtag.assigned_profile
    order = profile.customer_orders.joins(:online_order).find_by(online_orders: { counter: atts[:customer_order_id] })
    order.online_order.update!(redeemed: true)
  end
end
