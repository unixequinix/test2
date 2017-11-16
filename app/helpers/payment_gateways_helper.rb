module PaymentGatewaysHelper
  def store_redirection(event, type, options = {})
    if type == :refund
      return send("new_event_#{type}_path", event) unless event.payment_gateways&.vouchup&.refund&.any?
    else
      return send("new_event_#{type}_path", event) unless event.payment_gateways&.vouchup&.topup&.any?
    end

    params = { path: "/register/#{event.slug}/glownet/#{current_customer.id}" }
    params = { path: "/refund/#{event.slug}/customer-details", query: { email: current_customer.email, gtag: options[:gtag_uid] }.to_param } if type == :refund # rubocop:disable Metrics/LineLength

    url = { host: YAML.load_file(Rails.root.join('config', 'glownet', 'payment_gateways.yml'))["vouchup"]["host"][Rails.env] }.merge(params)

    URI::HTTP.build(url).to_s
  end
end
