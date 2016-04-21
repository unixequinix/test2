class Orders::IdealPresenter < Orders::BasePresenter
  attr_accessor :event, :order, :storage_id, :javascript_url

  def initialize(event, order)
    @event = event
    @order = order

    post_datastorage
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

  def post_datastorage
    data ="D200001seamless97UQQJTP0Qhttp://2bad6936.ngrok.io/frontend/fallback_return.phpENB8AKTPWBRMNBV455FG6M2DANE99WU2"
    key = "B8AKTPWBRMNBV455FG6M2DANE99WU2"
    digest = OpenSSL::Digest.new('sha512')
    hmac = OpenSSL::HMAC.hexdigest(digest, key, data)

    params = {
      customerid: "D200001",
      shopId: "seamless",
      orderIdent: "97UQQJTP0Q",
      returnUrl: "http://2bad6936.ngrok.io/frontend/fallback_return.php",
      language: "EN",
      requestFingerprint: hmac
    }

    response = Net::HTTP.post_form(URI.parse("https://checkout.wirecard.com/seamless/dataStorage/init"), params)
    hash = response.body.split("&").map { |it| URI.decode_www_form(it).first }.to_h
    @storage_id = hash["storageId"]
    @javascript_url = hash["javascriptUrl"]
  end
end
