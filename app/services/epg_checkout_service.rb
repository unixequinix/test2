class EpgCheckoutService
  include Rails.application.routes.url_helpers

  def initialize(claim, epg_claim_form)
    @claim = claim
    @epg_claim_form = epg_claim_form
  end

  def url
    value = create_value
    md5key = Rails.application.secrets.epg_md5key
    sha256ParamsIntegrityCheck = Digest::SHA256.hexdigest(value)

    encrypted = crypt(value, md5key)
    encryptedValue = encrypted

    parameters = {
      'merchantId' => Rails.application.secrets.epg_merchant_id,
      'encrypted' => encryptedValue,
      'integrityCheck' => sha256ParamsIntegrityCheck
    }

    uri = URI.parse(Rails.application.secrets.epg_url)
    uri.query = URI.encode_www_form(parameters)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    response = http.request(request).body
  end

  private

  def crypt(value, key)
    cipher = OpenSSL::Cipher::AES.new(256, :ECB)
    cipher.encrypt
    cipher.padding = 1
    cipher.key = key
    result = cipher.update(value) + cipher.final
    Base64.encode64(result)
  end

  def create_value
    value = "amount=#{@claim.total}"
    value += "&country=#{Rails.application.secrets.epg_country}"
    value += "&language=#{I18n.locale.to_s}"
    value += "&currency=#{Rails.application.secrets.epg_currency}"
    value += "&state=#{@epg_claim_form.state}"
    value += "&city=#{@epg_claim_form.city}"
    value += "&postCode=#{@epg_claim_form.post_code}"
    value += "&telephone=#{@epg_claim_form.phone}"
    value += "&addressLine1=#{@epg_claim_form.address}"
    value += "&customerEmail=#{@claim.customer.email}"
    value += "&firstName=#{@claim.customer.name}"
    value += "&lastName=#{@claim.customer.surname}"
    value += "&customerId=#{@claim.customer.id}"
    value += "&merchantId=#{Rails.application.secrets.epg_merchant_id}"
    value += "&merchantTransactionId=#{@claim.number}"
    value += "&operationType=#{Rails.application.secrets.epg_operation_type}"
    value += "&paymentSolution=#{Rails.application.secrets.epg_payment_solution}"
    value += "&successURL=#{success_customers_refunds_url}"
    value += "&errorURL=#{error_customers_refunds_url}"
    value += "&statusURL=#{customers_refunds_url}"
  end

end
