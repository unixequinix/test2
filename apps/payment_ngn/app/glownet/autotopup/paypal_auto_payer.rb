class Autotopup::PaypalAutoPayer
  def initialize(customer_event_profile)
    @customer_event_profile = customer_event_profile
    @event = customer_event_profile.event
    @order = Order.new
  end

  def start
    payment_gateway =
      @customer_event_profile.payment_gateway_customers.find_by(gateway_type: "paypal")
    return "No agreement accepted" if payment_gateway.nil?
    generate_order(payment_gateway)
    Payments::BraintreeDataRetriever.new(@event, @order)
    charge_object =
      pay(event_id: @event.id, order_id: @order.id, customer_id: payment_gateway.token)
  end

  private

  def generate_order(payment_gateway)
    @order.customer_event_profile = @customer_event_profile
    @order.generate_order_number!
    standard_credit = @event.credits.standard
    @order.order_items << OrderItem.new(
      catalog_item_id: standard_credit.catalog_item.id,
      amount: payment_gateway.autotopup_amount,
      total: payment_gateway.autotopup_amount * standard_credit.value
    )
    @order.save
  end

  def pay(params)
    charge_object = Payments::PaypalPayer.new
                    .start(params,
                           CustomerOrderCreator.new,
                           CustomerCreditOrderCreator.new,
                           "auto")
    charge_object.success? ? "Payment completed" : charge_object.errors.to_json
  end
end
