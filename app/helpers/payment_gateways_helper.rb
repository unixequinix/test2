module PaymentGatewaysHelper
  def store_redirection(event)
    return new_event_order_path(event) unless event.payment_gateways.topup.pluck(:name).include?('vouchup')

    url = "dev.wiredlion.io/register"
    url = "wiredlion.io/register" if Rails.env.production?
    url = "demo.wiredlion.io/register" if Rails.env.sandbox?

    "https://#{url}/#{event.slug}/glownet/#{current_customer.id}"
  end
end
