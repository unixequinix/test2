class EpgCheckout
  include Rails.application.routes.url_helpers

  def initialize(claim, epg_claim_form)
    @claim = claim
    @epg_claim_form = epg_claim_form
    eps = EventParameter.select(:value, "parameters.name")
      .joins(:parameter).where(
        event_id: claim.customer_event_profile.event_id,
        parameters: { category: 'refund', group: 'epg' }
      )
    @epg_values = Hash[eps.map{ |ep| [ep.name.to_sym, ep.value] }]
  end

  def url
    value = create_value
    md5key = @epg_values[:md5key]
    sha256ParamsIntegrityCheck = Digest::SHA256.hexdigest(value)

    encrypted = crypt(value, md5key)
    encryptedValue = encrypted

    parameters = {
      'merchantId' => @epg_values[:merchant_id],
      'encrypted' => encryptedValue,
      'integrityCheck' => sha256ParamsIntegrityCheck
    }

    uri = URI.parse(@epg_values[:url])
    uri.query = URI.encode_www_form(parameters)
    binding.pry
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    response = http.request(request).body
    binding.pry
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
    valid_characters = /[^0-9A-Za-zñÑ\-,'"ªº]/

    value = "amount=#{@claim.gtag.refundable_amount_after_fee(Claim::EASY_PAYMENT_GATEWAY)}"
    value += "&country=#{@epg_values[:country]}"
    value += "&language=#{I18n.locale.to_s}"
    value += "&currency=#{@epg_values[:currency]}"
    value += "&state=#{@epg_claim_form.state.gsub(valid_characters, ' ')}"
    value += "&city=#{@epg_claim_form.city.gsub(valid_characters, ' ')}"
    value += "&postCode=#{@epg_claim_form.post_code.gsub(valid_characters, ' ')}"
    value += "&telephone=#{@epg_claim_form.phone}"
    value += "&addressLine1=#{@epg_claim_form.address.gsub(valid_characters, ' ')}"
    value += "&customerEmail=#{@claim.customer_event_profile.customer.email}"
    value += "&firstName=#{@claim.customer_event_profile.customer.name}"
    value += "&lastName=#{@claim.customer_event_profile.customer.surname}"
    value += "&customerId=#{@claim.customer_event_profile.customer.id}"
    value += "&merchantId=#{@epg_values[:merchant_id]}"
    value += "&productId=#{@epg_values[:product_id]}"
    value += "&merchantTransactionId=#{@claim.number}"
    value += "&operationType=#{@epg_values[:operation_type]}"
    value += "&paymentSolution=#{@epg_values[:payment_solution]}"
    value += "&successURL=#{success_event_refunds_url(@claim.customer_event_profile.event)}"
    value += "&errorURL=#{error_event_refunds_url(@claim.customer_event_profile.event)}"
    value += "&statusURL=#{event_refunds_url(@claim.customer_event_profile.event)}"
  end

end
