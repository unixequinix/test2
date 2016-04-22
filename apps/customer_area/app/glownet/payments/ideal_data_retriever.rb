class Payments::IdealDataRetriever < Payments::BaseDataRetriever
  include Rails.application.routes.url_helpers
  attr_reader :current_event, :order

  def initialize(event, order)
    @current_event = event
    @order = order
    @payment_parameters = Parameter.joins(:event_parameters)
                          .where(category: "payment",
                                 group: "ideal",
                                 event_parameters: { event: event })
                          .select("parameters.name, event_parameters.*")
  end

  def with_params(params)
    @financial_institution = params[:financial_institution]
    @ip = params[:consumer_ip_address]
    @user_agent = params[:consumer_user_agent]
    self
  end

  def customer_id
    get_value_of_parameter("customer_id")
  end

  def language
    I18n.locale.to_s
  end

  def payment_type
    "IDL"
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

  def success_url
    event_order_payment_service_asynchronous_payments_url(@current_event, @order, "ideal")
  end

  def cancel_url
    "http://2bad6936.ngrok.io/frontend/fallback_return.php"
  end

  def failure_url
    "http://2bad6936.ngrok.io/frontend/fallback_return.php"
  end

  def service_url
    "http://2bad6936.ngrok.io/frontend/fallback_return.php"
  end

  def confirm_url
    "http://2bad6936.ngrok.io/frontend/fallback_return.php"
  end

  def customer_statement
    "Customer Event Profile: #{@order.customer_event_profile.id}"
  end

  def order_reference
    @order.id
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

  def secret_key
    get_value_of_parameter("secret_key")
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

  def parameters
    {
      customerId: "customer_id",
      language: "language",
      paymentType: "payment_type",
      amount: "amount",
      currency: "currency",
      orderDescription: "order_description",
      successUrl: "success_url",
      cancelUrl: "cancel_url",
      failureUrl: "failure_url",
      serviceUrl: "service_url",
      confirmUrl: "confirm_url",
      customerStatement: "customer_statement",
      orderReference: "order_reference",
      consumerIpAddress: "consumer_ip_address",
      consumerUserAgent: "consumer_user_agent",
      financialInstitution: "financial_institution"
    }
  end

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.try(:value)
  end
end
