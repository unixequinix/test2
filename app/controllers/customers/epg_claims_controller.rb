class Customers::EpgClaimsController < Customers::BaseController
  before_action :check_has_gtag!
  # before_action :require_permission!, only: [:create, :update]

  def new
    @epg_claim_form = EpgClaimForm.new(current_customer)
  end

  def create
    @epg_claim_form = EpgClaimForm.new(current_customer)
    if @epg_claim_form.submit(params[:epg_claim_form])
      flash[:notice] = I18n.t('alerts.created')
      redirect_to refund_url(@epg_claim_form.claim)
    else
      flash[:error] = @claim.errors.full_messages.join(". ")
      render :new
    end
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

  def refund_url(claim)
    value = "amount=#{claim.total}"
    value += "&country=MT"
    value += "&language=es"
    value += "&currency=EUR"
    value += "&state=Barcelona"
    value += "&city=Barcelona"
    value += "&postCode=28010"
    value += "&telephone=+34950123234"
    value += "&addressLine1=Gran via 1, Madrid"
    value += "&customerEmail=#{claim.customer.email}"
    value += "&firstName=#{claim.customer.name}"
    value += "&lastName=#{claim.customer.surname}"
    value += "&customerId=#{claim.customer.id}"
    value += "&merchantId=1067"
    value += "&merchantTransactionId=#{claim.number}"
    value += "&operationType=credit"
    value += "&paymentSolution=entercash"
    value += "&successURL=#{success_customers_refunds_url}"
    value += "&errorURL=#{error_customers_refunds_url}"
    value += "&statusURL=#{customers_refunds_url}"

    md5key = '05a5e6fa2a3294f9b4e5db504208f019'
    sha256ParamsIntegrityCheck = Digest::SHA256.hexdigest(value)

    encrypted = crypt(value, md5key)
    encryptedValue = encrypted

    parameters = {
      'merchantId' => 1067,
      'encrypted' => encryptedValue,
      'integrityCheck' => sha256ParamsIntegrityCheck
    }

    uri = URI.parse('https://staging.easypaymentgateway.com/EPGCheckout/rest/online/tokenize')
    uri.query = URI.encode_www_form(parameters)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    response = http.request(request).body
  end

  def require_permission!
    @claim = Claim.find(params[:id])
    if current_customer != @claim.customer || @claim.completed?
      flash.now[:error] = I18n.t('alerts.claim_complete') if @claim.completed?
      redirect_to customer_root_path
    end
  end

end