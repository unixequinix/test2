class Payments::WirecardBaseDataRetriever < Payments::BaseDataRetriever
  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order

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

  def language
    I18n.locale.to_s
  end

  def payment_type
    "SELECT"
  end

  def amount
    @order.total_formated
  end

  def currency
    @current_event.currency
  end

  def order_description
    "Order Number #{@order.id}"
  end

  def success_url(method)
    success_event_order_payment_service_asynchronous_payments_url(@current_event, @order, method)
  end

  def cancel_url
    "http://2bad6936.ngrok.io/frontend/service_url.php"
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

  def customer_statement
    "Customer Event Profile: #{@order.customer_event_profile.id}"
  end

  def order_reference
    @order.id
  end

  def order_ident
    @order.number
  end

  def consumer_ip_address
    @ip
  end

  def consumer_user_agent
    @user_agent
  end

  def financial_institution
    @financial_institution
  end

  def storage_id
    @storage_id
  end

  def secret_key
    get_value_of_parameter("secret_key")
  end

  def auto_deposit
    "no"
  end

  def duplicate_request_check
    "false"
  end

  def window_name
    "ventanaker"
  end

  def shop_id
    "qmore"
  end

  def noscript_info_url
    "http://2bad6936.ngrok.io/frontend/service_url.php"
  end

  def request_fingerprint_order
    parameters.keys.join(",") + ",requestFingerprintOrder,secret"
  end

  def request_fingerprint
    data = parameters.values.reduce("") { |acum, param| acum + send(param).to_s}
    data += request_fingerprint_order + secret_key
    digest = OpenSSL::Digest.new('sha512')
    hmac = OpenSSL::HMAC.hexdigest(digest, secret_key, data)
  end

  def url_for_redirection
    response = Net::HTTP.post_form(URI.parse("https://checkout.wirecard.com/seamless/frontend/init"), post_parameters)
    response_hash = response.body.split("&").map { |it| URI.decode_www_form(it).first }.to_h
    response_hash["redirectUrl"]
  end

  private

  def post_parameters
    post_parameters = Hash.new
    parameters.each { |k, v| post_parameters[k] = send(v) }
    post_parameters[:requestFingerprintOrder] = request_fingerprint_order
    post_parameters[:requestFingerprint] = request_fingerprint
    post_parameters
  end

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.try(:value)
  end


end
