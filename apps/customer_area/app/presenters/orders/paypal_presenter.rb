class Orders::PaypalPresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
  end

  def enable_autotoup_agreement?
    @event.get_parameter("payment", "braintree", "autotopup") == "true" &&
      !@order.customer_event_profile.gateway_customer(EventDecorator::PAYPAL)
  end

  def path
    "events/orders/paypal_payment_form"
  end

  def form_data
    Payments::BraintreeDataRetriever.new(@event, @order)
  end

  def payment_service
    "paypal"
  end
end
