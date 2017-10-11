module PaymentGatewaysHelper
  def store_redirection(event, type, options = {})
    return send("new_event_#{type}_path", event) unless event.payment_gateways.vouchup.any?

    host = YAML.load_file(Rails.root.join('config', 'glownet', 'payment_gateways.yml'))["vouchup"]["host"][Rails.env]

    params = { path: "/register/#{event.slug}/glownet/#{current_customer.id}" }
    params = { path: "/refund/#{event.slug}/customer-details", query: "email=#{current_customer.email}&gtag=#{options[:gtag_id]}" } if type == :refund

    "https://#{URI::HTTP.build({ host: host }.merge(params))}"
  end
end
