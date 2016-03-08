class TipaltiCheckout
  def initialize(claim)
    @claim = claim
    tps = EventParameter.select(:value, "parameters.name")
          .joins(:parameter).where(
            event_id: @claim.customer_event_profile.event_id,
            parameters: { category: "refund", group: "tipalti" }
          )
    @tipalti_values = Hash[tps.map { |tp| [tp.name.to_sym, tp.value] }]
  end

  def url
    "#{@tipalti_values[:url]}?#{create_value}&hashkey=#{crypt(create_value)}"
  end

  def create_value
    valid_characters = /[^0-9A-Za-z]/

    {
      idap: @claim.customer_event_profile.id,
      last: @claim.customer_event_profile.customer.last_name.gsub(valid_characters, ""),
      first: @claim.customer_event_profile.customer.first_name.gsub(valid_characters, ""),
      ts: Time.now.to_i,
      payer: @tipalti_values[:payer]
    }.to_param
  end

  def crypt(value)
    sha256 = OpenSSL::Digest.new("sha256")
    result = OpenSSL::HMAC.digest(sha256, @tipalti_values[:secret_key], value)
    result.each_byte.map { |b| b.to_s(16).rjust(2, "0") }.join
  end
end
