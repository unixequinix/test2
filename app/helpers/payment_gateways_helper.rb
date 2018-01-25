module PaymentGatewaysHelper
  def store_redirection(event, type, options = {})
    if type == :refund
      return new_event_refund_path(event) unless event.auto_refunds?
      params = { path: "/refund/#{event.slug}/customer-details", query: { email: current_customer.email, gtag: options[:gtag_uid] }.to_param }
    else
      params = { path: "/register/#{event.slug}/glownet/#{current_customer.id}" }
    end

    url = { host: Rails.application.secrets.wiredlion_host }.merge(params)

    URI::HTTP.build(url).to_s
  end
end
