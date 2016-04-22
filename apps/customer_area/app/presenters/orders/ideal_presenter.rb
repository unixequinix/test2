class Orders::IdealPresenter < Orders::BasePresenter
  attr_accessor :event, :order, :storage_id, :javascript_url

  def initialize(event, order)
    @event = event
    @order = order

    post_payment
  end

  def path
    "events/orders/ideal/payment_form"
  end

  def form_data
    Payments::IdealDataRetriever.new(@event, @order)
  end

  def payment_service
    "ideal"
  end

  def banks
    [
      ["ABN AMRO Bank", "ABNAMROBANK"],
      ["ASN Bank", "ASNBANK"],
      ["ING", "INGBANK"],
      ["knab", "KNAB"],
      ["Rabobank", "RABOBANK"],
      ["SNS Bank", "SNSBANK"],
      ["RegioBank", "REGIOBANK"],
      ["Triodos Bank", "TRIODOSBANK"],
      ["Van Lanschot Bankiers", "VANLANSCHOT"]
    ]
  end

  def post_payment
    params = {
      customerId: "D200001",
      language:  I18n.locale.to_s,
      paymentType: "IDL",
      amount: @order.total_formated,
      currency: @event.currency,
      orderDescription: "Order Number #{@order.id}",
      successUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      cancelUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      failureUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      serviceUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      confirmUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      customerStatement: "Customer Event Profile: #{@order.customer_event_profile.id}",
      orderReference: @order.id,
      consumerIpAddress: $view_context.request.ip,
      consumerUserAgent: $view_context.request.user_agent,
      financialInstitution: "Rabobank"
    }

    post_params = {
      customerId: params[:customerId],
      language: params[:language],
      paymentType: params[:paymentType],
      amount: params[:amount],
      currency: params[:currency],
      orderDescription: params[:orderDescription],
      successUrl: params[:successUrl],
      cancelUrl: params[:cancelUrl],
      failureUrl: params[:failureUrl],
      serviceUrl: params[:serviceUrl],
      confirmUrl: params[:confirmUrl],
      customerStatement: params[:customerStatement],
      orderReference: params[:orderReference],
      consumerIpAddress: params[:consumerIpAddress],
      consumerUserAgent: params[:consumerUserAgent],
      financialInstitution: params[:financialInstitution],
      requestFingerprintOrder: finger_print_order(params),
      requestFingerprint: finger_print(params)
    }

    response = Net::HTTP.post_form(URI.parse("https://checkout.wirecard.com/seamless/frontend/init"), post_params)
    hash = response.body.split("&").map { |it| URI.decode_www_form(it).first }.to_h
  end

  def finger_print(params)
    key = "B8AKTPWBRMNBV455FG6M2DANE99WU2"
    data = params.values.join + finger_print_order(params) + key
    digest = OpenSSL::Digest.new('sha512')
    hmac = OpenSSL::HMAC.hexdigest(digest, key, data)
  end

  def finger_print_order(params)
    params.keys.join(",") + ",requestFingerprintOrder,secret"
  end
end
