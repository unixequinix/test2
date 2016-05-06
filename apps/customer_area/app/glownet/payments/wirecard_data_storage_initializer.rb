class Payments::WirecardDataStorageInitializer
  def initialize(**params)
    params.slice!(:customer_id, :shop_id, :order_ident, :return_url, :language, :secret_key)
    params.each { |name, value| instance_variable_set(:"@#{name}", value) }
  end

  def data_storage
    response = Net::HTTP.post_form(
      URI.parse("https://checkout.wirecard.com/seamless/dataStorage/init"),
      data_storage_params_with_fingerprint
    )
    response.body.split("&").map { |it| URI.decode_www_form(it).first }.to_h
  end

  private

  def data_storage_params_with_fingerprint
    data_storage_params.merge(requestFingerprint: fingerprint)
  end

  def data_storage_params
    {
      customerid: @customer_id,
      shopId: @shop_id,
      orderIdent: @order_ident,
      returnUrl: @return_url,
      language: @language
    }
  end

  def fingerprint
    digest = OpenSSL::Digest.new("sha512")
    OpenSSL::HMAC.hexdigest(digest, @secret_key, data_string)
  end

  def data_string
    data_string = data_storage_params.values.reduce("") { |a, e| a + e.to_s }
    data_string + @secret_key
  end
end
