module PaymentGatewaysHelper
  def store_redirection(event)
    return new_event_order_path(event) unless event.payment_gateways.topup.pluck(:name).include?('vouchup')

    url = Rails.env.production? ? "wiredlion.io/register" : "dev.wiredlion.io/register"
    "https://#{url}/#{event.slug}/glownet/#{current_customer.id}"
  end
end
