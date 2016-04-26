class Payments::WirecardDataRetriever < Payments::WirecardBaseDataRetriever
  def with_params(params)
    @ip = params[:consumer_ip_address]
    @user_agent = params[:consumer_user_agent]
    self
  end

  def payment_type
    "CCARD"
  end

  def shop_id
    "Glownet"
  end

  def order_ident
    "97UQQJTP0Q"
  end

  def return_url
    "http://2bad6936.ngrok.io/frontend/fallback_return.php"
  end

  def data_storage_params
    {
      customerid: "customer_id",
      shopId: "shop_id",
      orderIdent: "order_ident",
      returnUrl: "return_url",
      language: "language",
    }
  end

  def post
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
    response.body.split("&").map { |it| URI.decode_www_form(it).first }.to_h
  end

  def data_storage
    @response_hash ||= post
  end

end



