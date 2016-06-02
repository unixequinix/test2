class Orders::PaypalNvpPresenter < Orders::BasePresenter
  attr_accessor :event, :order, :payer_id, :token

  def initialize(event, order)
    @event = event
    @order = order
    @profile = @order.profile
    @agreement = @profile.gateway_customer(EventDecorator::PAYPAL_NVP)
    @payer_id = ""
    @token = ""
    @email = ""
  end

  def with_params(params)
    @payer_id = params[:PayerID]
    @token = params[:token]
    self
  end

  def enable_autotoup_agreement?
    @event.get_parameter("payment", "paypal_nvp", "autotopup") == "true" && !@agreement
  end

  def merchant_id
    @event.get_parameter("payment", "paypal_nvp", "merchant_id")
  end

  def actual_agreement_state(namespace = "")
    namespace += "_" if namespace.present?
    @agreement ? "#{namespace}with_agreement" : "#{namespace}without_agreement"
  end

  def path(namespace = "")
    namespace += "_" if namespace.present?
    partial = (@payer_id || @agreement) ? "#{namespace}payment_final" : "#{namespace}payment_form"
    "events/orders/paypal_nvp/#{partial}"
  end

  def email
    @profile.customer.email
  end

  def form_data
    Payments::PaypalNvp::DataRetriever.new(@event, @order)
  end

  def payment_service
    "paypal_nvp"
  end
end
