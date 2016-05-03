class Payments::WirecardBaseDataRetriever < Payments::BaseDataRetriever
  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order

  def with_params(params)
    @ip = params[:consumer_ip_address]
    @user_agent = params[:consumer_user_agent]
    self
  end

  def initialize(event, order)
    @current_event = event
    @order = order
    @payment_parameters = Parameter.joins(:event_parameters)
                          .where(category: "payment",
                                 group: "wirecard",
                                 event_parameters: { event: event })
                          .select("parameters.name, event_parameters.*")
  end

  def customer_id
    get_value_of_parameter("customer_id")
  end

  def amount
    @order.total_formated
  end

  def currency
    @current_event.currency
  end

  def payment_type
    "SELECT"
  end

  def language
    I18n.locale.to_s
  end

  def order_description
    "Order Number #{@order.number}"
  end

  def success_url(method)
    success_event_order_payment_service_asynchronous_payments_url(@current_event, @order, method)
  end

  def cancel_url
    error_event_order_payment_service_asynchronous_payments_url(@current_event, @order.id, method)
  end

  def failure_url(method)
    error_event_order_payment_service_asynchronous_payments_url(@current_event, @order.id, method)
  end

  def service_url
    "http://2bad6936.ngrok.io/frontend/service_url.php"
  end

  def confirm_url(method)
    event_order_payment_service_asynchronous_payments_url(@current_event, @order, method)
  end

  def consumer_user_agent
    @user_agent
  end

  def consumer_ip_address
    @ip
  end

  def secret_key
    get_value_of_parameter("secret_key")
  end

  def url_for_redirection
    response = Net::HTTP.post_form(
      URI.parse("https://checkout.wirecard.com/seamless/frontend/init"),
      payment_parameters
    )
    response_hash = response.body.split("&").map { |it| URI.decode_www_form(it).first }.to_h
    response_hash["redirectUrl"]
  end

  private

  def request_fingerprint_order
    parameters.keys.join(",") + ",requestFingerprintOrder,secret"
  end

  def request_fingerprint
    data = parameters.values.reduce("") { |a, e| a + send(e).to_s }
    data += request_fingerprint_order + secret_key
    digest = OpenSSL::Digest.new("sha512")
    OpenSSL::HMAC.hexdigest(digest, secret_key, data)
  end

  def payment_parameters
    payment_parameters = {}
    parameters.each { |k, v| payment_parameters[k] = send(v) }
    payment_parameters[:requestFingerprintOrder] = request_fingerprint_order
    payment_parameters[:requestFingerprint] = request_fingerprint
    payment_parameters
  end

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.try(:value)
  end

  def parameters
    {
      customerId: "customer_id", amount: "amount", currency: "currency",
      paymentType: "payment_type", language: "language", orderDescription: "order_description",
      successUrl: "success_url", cancelUrl: "cancel_url", failureUrl: "failure_url",
      serviceUrl: "service_url", confirmUrl: "confirm_url",
      consumerUserAgent: "consumer_user_agent", consumerIpAddress: "consumer_ip_address"
    }
  end
end
