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

  def actual_agreement_state
    @agreement ? "with_agreement" : "without_agreement"
  end

  def merchant_id
    @event.get_parameter("payment", "paypal_nvp", "merchant_id")
  end

  def path
    partial = (@payer_id || @agreement) ? "payment_final" : "payment_form"
    "events/orders/paypal_nvp/#{partial}"
  end

  def autotopup_path
    partial = (@payer_id || @agreement) ? "autotopup_payment_final" : "autotopup_payment_form"
    "events/orders/paypal_nvp/#{partial}"
  end

  def email
    @profile.customer.email
  end

  def form_data
    Payments::PaypalNvpDataRetriever.new(@event, @order)
  end

  def payment_service
    "paypal_nvp"
  end
end
