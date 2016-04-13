class Orders::PaypalNvpPresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
    @customer_event_profile = @order.customer_event_profile
    @agreement = @customer_event_profile.gateway_customer(EventDecorator::PAYPAL_NVP)
  end

  def enable_autotoup_agreement?
    @event.get_parameter("payment", "paypal_nvp", "autotopup") == "true" && !@agreement
  end

  def actual_agreement_state
    @agreement ? "with_agreement" : "without_agreement"
  end

  def path
    "events/orders/paypal_nvp_payment_redirection"
  end

  def form_data
    Payments::PaypalNvpDataRetriever.new(@event, @order)
  end

  def email
    @customer_event_profile.customer.email
  end

  def payment_service
    "paypal_nvp"
  end
end
