class Orders::IdealPresenter < Orders::BasePresenter
  attr_accessor :event, :order, :storage_id, :javascript_url

  def initialize(event, order)
    @event = event
    @order = order

    post
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

  def post
    params = {
      customerId: "D200001",
      language: "EN",
      paymentType: "IDL",
      amount: 17,
      currency: "EUR",
      orderDescription: "Mondongos",
      successUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      cancelUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      failureUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      serviceUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      confirmUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      consumerIpAddress: $view_context.request.ip,
      consumerUserAgent: $view_context.request.user_agent,
      financialInstitution: "Rabobank",
      requestFingerprintOrder: "customerId,language,paymentType,amount,currency,orderDescription,successUrl,cancelUrl,failureUrl,serviceUrl,confirmUrl,consumerIpAddress,consumerUserAgent,financialInstitution,requestFingerprintOrder,requestFingerprint",
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
      consumerIpAddress: params[:consumerIpAddress],
      consumerUserAgent: params[:consumerUserAgent],
      financialInstitution: params[:financialInstitution],
      requestFingerprintOrder: params[:requestFingerprintOrder],
      requestFingerprint: finger_print(params)
    }

    response = Net::HTTP.post_form(URI.parse("https://checkout.wirecard.com/seamless/frontend/init"), post_params)
    hash = response.body.split("&").map { |it| URI.decode_www_form(it).first }.to_h
    binding.pry
    @storage_id = hash["storageId"]
    @javascript_url = hash["javascriptUrl"]
  end

  def finger_print(params)
    key = "B8AKTPWBRMNBV455FG6M2DANE99WU2"
    data = params.values.join
    digest = OpenSSL::Digest.new('sha512')
    hmac = OpenSSL::HMAC.hexdigest(digest, key, data)
  end

  def finger_print_order(params)
    params.keys.join(",")

  end
end
