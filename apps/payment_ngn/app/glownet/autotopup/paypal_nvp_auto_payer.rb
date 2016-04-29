class Autotopup::PaypalNvpAutoPayer
  def self.start(tag_uid, order_id, event) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    profile = event.gtags.find_by_tag_uid(tag_uid)&.assigned_customer_event_profile
    return { errors: "Customer not found" } if profile.nil?
    credit = event.credits.standard

    p_gateway = profile.payment_gateway_customers.find_by(gateway_type: "paypal_nvp")
    return { errors: "No agreement accepted" } if p_gateway.nil?

    order = Order.new(customer_event_profile: profile, number: order_id)
    amount = p_gateway.autotopup_amount
    value = credit.value
    order.order_items << OrderItem.new(catalog_item_id: credit.catalog_item.id,
                                       amount: amount,
                                       total: amount * value)
    order.save

    data = { event_id: event.id, order_id: order.id }
    charge = Payments::PaypalNvpPayer.new.start(data,
                                                CustomerOrderCreator.new,
                                                CustomerCreditOrderCreator.new)

    return { errors: charge.errors.to_json } unless charge["ACK"] == "Success"
    { gtag_uid: tag_uid, credit_amount: amount, money_amount: amount * value, credit_value: value }
  end
end
