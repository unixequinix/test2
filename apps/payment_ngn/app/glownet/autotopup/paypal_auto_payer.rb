class Autotopup::PaypalAutoPayer
  def self.start(tag_uid, order_id, event) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    profile = event.gtags.find_by_tag_uid(tag_uid)&.assigned_profile
    return { errors: "Customer not found" } unless profile
    credit = event.credits.standard

    p_gateway = profile.payment_gateway_customers.find_by(gateway_type: "paypal")
    return { errors: "No agreement accepted" } unless p_gateway

    order = Order.create!(profile: profile, number: order_id)
    amount = p_gateway.autotopup_amount
    value = credit.value
    total = amount * value
    order.order_items.create!(catalog_item: credit.catalog_item, amount: amount, total: total)

    Payments::PaypalDataRetriever.new(event, order)

    data = { event_id: event.id, order_id: order.id }
    charge = Payments::PaypalPayer.new.start(data,
                                             CustomerOrderCreator.new,
                                             CustomerCreditAutotopupOrderCreator.new)

    return { errors: charge.errors.to_json } unless charge.success?
    { gtag_uid: tag_uid, credit_amount: amount, money_amount: total, credit_value: value }
  end
end
