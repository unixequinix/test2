class TipaltiCheckout
  include Rails.application.routes.url_helpers

  def initialize(claim)
    @claim = claim
    tps = EventParameter.select(:value, "parameters.name")
                        .joins(:parameter).where(
                          event_id: @claim.profile.event_id,
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
      idap: @claim.profile.id,
      last: @claim.profile.customer.last_name.gsub(valid_characters, ""),
      first: @claim.profile.customer.first_name.gsub(valid_characters, ""),
      ts: Time.zone.now.to_i,
      payer: @tipalti_values[:payer],
      redirectTo: success_event_refunds_url(@claim.profile.event)
    }.to_param
  end

  def crypt(value)
    sha256 = OpenSSL::Digest.new("sha256")
    result = OpenSSL::HMAC.digest(sha256, @tipalti_values[:secret_key], value)
    result.each_byte.map { |b| b.to_s(16).rjust(2, "0") }.join
  end
end
