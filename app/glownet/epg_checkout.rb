class EpgCheckout
  include Rails.application.routes.url_helpers

  def initialize(claim, epg_claim_form)
    @claim = claim
    @epg_claim_form = epg_claim_form
    @event = @claim.profile.event
    eps = @event.event_parameters
                .includes(:parameter)
                .where(parameters: { category: "refund", group: "epg" })
                .pluck(:name, :value)
    @epg_values = Hash[eps].symbolize_keys!
  end

  def url
    value = create_value
    md5key = @epg_values[:md5key]
    atts = { merchantId: @epg_values[:merchant_id],
             encrypted: crypt(value, md5key),
             integrityCheck: Digest::SHA256.hexdigest(value) }
    uri = URI.parse(@epg_values[:url])
    uri.query = URI.encode_www_form(atts)
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

  def create_value # rubocop:disable Metrics/MethodLength
    profile = @claim.profile
    customer = profile.customer
    event = profile.event

    {
      amount: profile.refundable_money_after_fee(Claim::EASY_PAYMENT_GATEWAY),
      country: @epg_values[:country],
      language: I18n.locale,
      currency: @epg_values[:currency],
      state: validate_characters(@epg_claim_form.state),
      city: validate_characters(@epg_claim_form.city),
      postCode: validate_characters(@epg_claim_form.post_code),
      telephone: @epg_claim_form.phone,
      addressLine1: validate_characters(@epg_claim_form.address),
      customerEmail: customer.email,
      firstName: customer.first_name,
      lastName: customer.last_name,
      customerId: customer.id,
      merchantId: @epg_values[:merchant_id],
      productId: @epg_values[:product_id],
      merchantTransactionId: @claim.number,
      operationType: @epg_values[:operation_type],
      paymentSolution: @epg_values[:payment_solution],
      successURL: success_event_refunds_url(event),
      errorURL: error_event_refunds_url(event),
      statusURL: event_refunds_url(event)
    }.to_param
  end

  def validate_characters(str)
    valid_characters = /[^0-9A-Za-zñÑ\-,'"ªº]/
    str.gsub(valid_characters, " ")
  end
end
