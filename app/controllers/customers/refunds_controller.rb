class Customers::RefundsController < Customers::BaseController

  # def encryptData(input, key)
  #   crypted = null
  #   SecretKeySpec skey = new SecretKeySpec(key.getBytes(), AES)
  #   Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding")
  #   cipher.init(Cipher.ENCRYPT_MODE, skey)
  #   crypted = cipher.doFinal(input.getBytes())
  #   return new String(Base64.encodeBase64(crypted))
  # end

#
  # def encryptData(input, key)
  #   cipher = OpenSSL::Cipher::AES.new(128, :ECB)
  #   cipher.encrypt
  #   cipher.key = key
  #   encrypted = cipher.update(input) + cipher.final
  #   return Base64.encode64(encrypted)
  # end
#
  # def new
#
  #   value = "account=netellertest_EUR@neteller.com";
  #   value += "&accountPassword=908379";
  #   value += "&amount=10";
  #   value += "&country=ES";
  #   value += "&currency=EUR";
  #   value += "&customerId=100";
  #   value += "&merchantId=1067";
  #   value += "&merchantTransactionId=12345";
  #   value += "&operationType=credit";
  #   value += "&paymentSolution=neteller";
#
  #   md5key = Digest::MD5.hexdigest('myPassWord1234')
  #   sha256ParamsIntegrityCheck = Digest::SHA256.hexdigest(value)
  #   encryptedValue = encryptData(value, md5key)
#
  #   parameters = {
  #     'merchantId' => 1067,
  #     'encrypted' => encryptedValue,
  #     'integrityCheck' => sha256ParamsIntegrityCheck
  #   }
#
  #   uri = URI.parse('https://staging.easypaymentgateway.com/EPGCheckout/rest/online/pay')
  #   uri.query = URI.encode_www_form(parameters)
  #   http = Net::HTTP.new(uri.host, uri.port)
  #   http.use_ssl = true
  #   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #   request = Net::HTTP::Post.new(uri.request_uri)
  #   http.request(request).body
#
  #   @encryptedValue = encryptData(value, md5key)
  #   @sha = sha256ParamsIntegrityCheck
  # end

  def new
    @refund = Refund.new
    @refund.build_bank_account
  end

  def create
    @refund = Refund.new(permitted_params)
    if @refund.save
      flash[:notice] = I18n.t('alerts.created')
      redirect_to customer_root_url
    else
      flash[:error] = @refund.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @refund = Refund.find(params[:id])
    @refund.build_bank_account unless current_customer.bank_account
  end

  def update
    @refund = Refund.find(params[:id])
    if @refund.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to customer_root_url
    else
      flash[:error] = @refund.errors.full_messages.join(". ")
      render :edit
    end
  end

  private

  def permitted_params
    params.require(:refund).permit(:customer_id, :gtag_id, bank_account_attributes: [:id, :customer_id, :iban, :swift])
  end

end
