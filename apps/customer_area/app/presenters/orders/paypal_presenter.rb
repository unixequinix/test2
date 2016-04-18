class Orders::PaypalPresenter < Orders::BasePresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
    @customer_event_profile = @order.customer_event_profile
    @agreement = @customer_event_profile.gateway_customer(EventDecorator::PAYPAL)
  end

  def enable_autotoup_agreement?
    @event.get_parameter("payment", "braintree", "autotopup") == "true" && !@agreement
  end

  def actual_agreement_state
    @agreement ? "with_agreement" : "without_agreement"
  end

  def path
    "events/orders/paypal/payment_form"
  end

  def email
    @agreement.email
  end

  def form_data
    Payments::PaypalDataRetriever.new(@event, @order)
  end

  def payment_service
    "paypal"
  end
end
