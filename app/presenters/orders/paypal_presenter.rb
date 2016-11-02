class Orders::PaypalPresenter < Orders::BasePresenter
  attr_accessor :event, :order

  def initialize(event, order)
    @event = event
    @order = order
    @profile = @order.profile
    @agreement = @profile.gateway_customer(EventDecorator::PAYPAL)
  end

  def enable_autotoup_agreement?
    @event.get_parameter("payment", "braintree", "autotopup") == "true" && !@agreement
  end

  def actual_agreement_state
    @agreement ? "with_agreement" : "without_agreement"
  end

  def path(namespace = "")
    namespace += "_" if namespace.present?
    "events/orders/paypal/#{namespace}payment_form"
  end

  def autotopup_path
    "events/orders/paypal/autotopup_payment_form"
  end

  def email
    @agreement.email
  end

  def form_data
    Payments::Paypal::DataRetriever.new(@event, @order)
  end

  def payment_service
    "paypal"
  end
end
