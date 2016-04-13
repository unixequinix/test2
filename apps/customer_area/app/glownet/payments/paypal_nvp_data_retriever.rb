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
    @hash_response = post_request
  end

  def post_request
    params = {
      "USER" => user,
      "PWD" => pwd,
      "SIGNATURE" => signature,
      "METHOD" => method,
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

  def form
    "https://www.sandbox.paypal.com/cgi-bin/webscr"
  end

  def cmd
    "_express-checkout"
  end

  def token
    @hash_response["TOKEN"].gsub("%2d", "-")
  end

  private

  def user
    "payments-facilitator_api1.glownet.com"
  end

  def pwd
    "GDSHHDFJ7KEBHVRB"
  end

  def signature
    "AFcWxV21C7fd0v3bYYYRCpSSRl31A4i6SeDVCt6M9xT2Cg08xXvNmpwK"
  end

  def method
    "SetExpressCheckout"
  end

  def version
    86
  end

  def payment_action
    "AUTHORIZATION"
  end

  def amt
    50
  end

  def currency_code
    "USD"
  end

  def billing_type
    "MerchantInitiatedBilling"
  end

  def billing_agreement_description
    "ClubUsage"
  end

  def cancel_url
    new_event_checkout_url(@current_event)
  end

  def return_url
    success_event_order_payment_service_synchronous_payments_url(@current_event, @order, "paypal_nvp")
  end

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.value
  end
end

