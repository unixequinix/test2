module PaymentGatewaysHelper
  def store_redirection(event, type, options = {})
    path = new_event_refund_path(event) if type == :refund
    path = new_event_order_path(event) if type == :order

    return path unless event.payment_gateways.topup.pluck(:name).include?('vouchup')

    host = YAML.load_file("#{Rails.root}/config/glownet/payment_gateways.yml")["vouchup"]["host"][Rails.env]
    full_uri = URI::HTTP.build(host: host, path: "/refund/#{event.slug}/customer-details", query: "email=#{current_customer.email}&gtag=#{options[:gtag_id]}") if type == :refund
    full_uri = URI::HTTP.build(host: host, path: "/register/#{event.slug}/glownet/#{current_customer.id}") if type == :order

    "https://#{full_uri}"
  end
end
