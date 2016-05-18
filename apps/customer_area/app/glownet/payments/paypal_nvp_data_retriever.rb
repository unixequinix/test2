class Payments::PaypalNvpDataRetriever < Payments::BaseDataRetriever
  require "uri"
  require "net/http"

  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order

  def with_params(params)
    @autotopup_agreement = params[:autotopup_agreement]
    @hash_response = @paypal_nvp.set_express_checkout(amount, cancel_url, return_url)
    self
  end

  def initialize(event, order)
    @current_event = event
    @order = order
    @paypal_nvp = Gateways::PaypalNvp::Transaction.new(event)
    email = @order.profile.customer.email
    @hash_response = @paypal_nvp.set_express_checkout(email, amount, cancel_url, return_url)
  end

  def form
    @current_event.get_parameter("payment", "paypal_nvp", "url")
  end

  def cmd
    "_express-checkout"
  end

  def token
    @hash_response["TOKEN"]
  end

  private

  def amount
    (@order.total * 100).floor
  end

  def cancel_url
    new_event_checkout_url(@current_event)
  end

  def return_url
    return event_order_url(current_event, @order) unless @autotopup_agreement
    new_event_autotopup_agreement_url(
      current_event,
      order_id: @order,
      payment_service: "paypal_nvp")
  end
end
