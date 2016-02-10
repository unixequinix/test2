class EpgCheckout
  include Rails.application.routes.url_helpers

  def initialize(claim, epg_claim_form)
    @claim = claim
    @epg_claim_form = epg_claim_form
    eps = EventParameter.select(:value, "parameters.name")
          .joins(:parameter)
          .where(event_id: claim.customer_event_profile.event_id,
                 parameters: { category: "refund", group: "epg" })
    @epg_values = Hash[eps.map { |ep| [ep.name.to_sym, ep.value] }]
  end

  def url
    value = create_value
    md5key = @epg_values[:md5key]
    sha256_params_integrity_check = Digest::SHA256.hexdigest(value)
    encrypted_value = crypt(value, md5key)
    parameters = { merchantId: @epg_values[:merchant_id], encrypted: encrypted_value,
                   integrityCheck: sha256_params_integrity_check }
    uri = URI.parse(@epg_values[:url])
    uri.query = URI.encode_www_form(parameters)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    http.request(request).body
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

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def create_value
    profile = @claim.customer_event_profile
    customer = profile.customer

    {
      amount: @claim.gtag.refundable_amount_after_fee(Claim::EASY_PAYMENT_GATEWAY),
      country: @epg_values[:country],
      language: I18n.locale,
      currency: @epg_values[:currency],
      state: validate_characters(@epg_claim_form.state),
      city: validate_characters(@epg_claim_form.city),
      postCode: validate_characters(@epg_claim_form.post_code),
      telephone: @epg_claim_form.phone,
      addressLine1: validate_characters(@epg_claim_form.address),
      customerEmail: customer.email,
      firstName: customer.name,
      lastName: customer.surname,
      customerId: customer.id,
      merchantId: @epg_values[:merchant_id],
      productId: @epg_values[:product_id],
      merchantTransactionId: @claim.number,
      operationType: @epg_values[:operation_type],
      paymentSolution: @epg_values[:payment_solution],
      successURL: success_event_refunds_url(profile.event),
      errorURL: error_event_refunds_url(profile.event),
      statusURL: event_refunds_url(profile.event)
    }.to_param
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def validate_characters(str)
    str.gsub(valid_characters, " ")
  end
end
