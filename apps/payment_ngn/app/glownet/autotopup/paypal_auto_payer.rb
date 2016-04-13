class Autotopup::PaypalAutoPayer
  def self.start(tag_uid, order_id) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    profile = Gtag.find_by_tag_uid(tag_uid)&.assigned_customer_event_profile
    return { errors: "Customer not found" } if profile.nil?
    event = profile.event
    credit = event.credits.standard

    p_gateway = profile.payment_gateway_customers.find_by(gateway_type: "paypal")
    return { errors: "No agreement accepted" } if p_gateway.nil?

    order = Order.new(customer_event_profile: profile, number: order_id)
    amount = p_gateway.autotopup_amount
    value = credit.value
    order.order_items << OrderItem.new(catalog_item_id: credit.catalog_item.id,
                                       amount: amount,
                                       total: amount * value)
    order.save
    Payments::BraintreeDataRetriever.new(event, order)

    data = { event_id: event.id, order_id: order.id }
    charge = Payments::PaypalPayer.new.start(data,
                                             CustomerOrderCreator.new,
                                             CustomerCreditOrderCreator.new)

    return { errors: charge.errors.to_json } unless charge.success?
    { gtag_uid: tag_uid, credit_amount: amount, money_amount: amount * value, credit_value: value }
  end
end
