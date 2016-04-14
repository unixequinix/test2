class Payments::PaypalNvpDataRetriever
  require "uri"
  require "net/http"

  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order

  def initialize(event, order)
    @current_event = event
    @order = order
    @payment_parameters = Parameter.joins(:event_parameters)
                          .where(category: "payment",
                                 group: "paypal_nvp",
                                 event_parameters: { event: event })
                          .select("parameters.name, event_parameters.*")
    @hash_response = set_express_checkout
  end

  def set_express_checkout
    params = {
      "USER" => user,
      "PWD" => pwd,
      "SIGNATURE" => signature,
      "METHOD" => "SetExpresscheckout",
      "VERSION" => version,
      "PAYMENTREQUEST_0_PAYMENTACTION" => payment_action,
      "PAYMENTREQUEST_0_AMT" => amt,
      "PAYMENTREQUEST_0_CURRENCYCODE" => currency_code,
      "L_BILLINGTYPE0" => billing_type,
      "L_BILLINGAGREEMENTDESCRIPTION0" => billing_agreement_description,
      "cancelUrl" => cancel_url,
      "returnUrl" => return_url
    }
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    response.body.split("&").map{|it|it.split("=")}.to_h
  end

  def get_express_checkout_details(token)
    params = {
      "METHOD" => "GetExpressCheckoutDetails",
      "TOKEN" => token
    }
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    response.body.split("&").map{|it|it.split("=")}.to_h
  end

  def do_express_checkout_payment(token, payer_id)
    params = {
      "METHOD" => "DoExpressCheckoutPayment",
      "TOKEN" => token,
      "PAYER_ID" => payer_id
    }
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    response.body.split("&").map{|it|it.split("=")}.to_h
  end

  def form
    "https://www.sandbox.paypal.com/cgi-bin/webscr"
  end

  def cmd
    "_express-checkout"
  end

  def token
    @hash_response["TOKEN"].gsub("%2d", "-")
  end

  def user_details
    @user_details
  end

  private

  def user
    get_value_of_parameter("user")
  end

  def pwd
    get_value_of_parameter("password")
  end

  def signature
    get_value_of_parameter("signature")
  end

  def version
    86
  end

  def payment_action
    "AUTHORIZATION"
  end

  def amt
    (@order.total * 100).floor
  end

  def currency_code
    get_value_of_parameter("currency")
  end

  def billing_type
    "MerchantInitiatedBilling"
  end

  def billing_agreement_description
    I18n.t('registration.autotoup_agreement.billing_agreement_description')
  end

  def cancel_url
    new_event_checkout_url(@current_event)
  end

  def return_url
    event_order_url(current_event, @order)
  end

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.value
  end
end

