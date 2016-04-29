class Payments::PaypalNvpDataRetriever < Payments::BaseDataRetriever
  require "uri"
  require "net/http"

  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order

  def initialize(event, order)
    @current_event = event
    @order = order
    @paypal_nvp = Gateways::PaypalNvp::Transaction.new(event)
    @hash_response = @paypal_nvp.set_express_checkout(amount, cancel_url, return_url)
  end

  def form
    "https://www.sandbox.paypal.com/cgi-bin/webscr"
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
    event_order_url(current_event, @order)
  end
end
