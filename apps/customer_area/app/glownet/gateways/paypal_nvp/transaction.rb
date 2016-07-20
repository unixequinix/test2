class Gateways::PaypalNvp::Transaction
  def initialize(event)
    @event = event
    @gateway_parameters = Parameter.joins(:event_parameters)
                                   .where(category: "payment", group: "paypal_nvp", event_parameters: { event: event })
                                   .select("parameters.name, event_parameters.*")
    @user = get_value_of_parameter("user")
    @password = get_value_of_parameter("password")
    @signature = get_value_of_parameter("signature")
    @currency = get_value_of_parameter("currency")
    @version = "86"
    @billing_type = "MerchantInitiatedBilling"
    @billing_agreement_description = I18n.t("registration.autotoup_agreement.billing_agreement_description")
  end

  def set_express_checkout(email, amount, cancel_url, return_url)
    post("USER" => @user,
         "PWD" => @password,
         "EMAIL" => email,
         "SIGNATURE" => @signature,
         "METHOD" => "SetExpresscheckout",
         "VERSION" => @version,
         "HDRIMG" => nil,
         "BRANDNAME" => @event.name,
         "PAYMENTREQUEST_0_PAYMENTACTION" => "AUTHORIZATION",
         "PAYMENTREQUEST_0_AMT" => amount,
         "PAYMENTREQUEST_0_CURRENCYCODE" => @currency,
         "L_BILLINGTYPE0" => @billing_type,
         "L_BILLINGAGREEMENTDESCRIPTION0" => @billing_agreement_description,
         "NOSHIPPING" => 1, "cancelUrl" => cancel_url, "returnUrl" => return_url)
  end

  def get_express_checkout_details(token)
    post("METHOD" => "GetExpressCheckoutDetails",
         "USER" => @user,
         "PWD" => @password,
         "SIGNATURE" => @signature,
         "VERSION" => @version,
         "TOKEN" => token)
  end

  def do_express_checkout_payment(amount, token, payer_id)
    post("METHOD" => "DoExpressCheckoutPayment",
         "TOKEN" => token,
         "PAYERID" => payer_id,
         "USER" => @user,
         "PWD" => @password,
         "SIGNATURE" => @signature,
         "VERSION" => @version,
         "PAYMENTREQUEST_0_AMT" => amount,
         "PAYMENTREQUEST_0_CURRENCYCODE" => @currency,
         "PAYMENTREQUEST_0_PAYMENTACTION" => "Sale")
  end

  def do_reference_transaction(amount, reference_id)
    post("METHOD" => "DoReferenceTransaction",
         "USER" => @user,
         "PWD" => @password,
         "SIGNATURE" => @signature,
         "VERSION" => @version,
         "AMT" => amount,
         "CURRENCYCODE" => @currency,
         "PAYMENTACTION" => "SALE",
         "REFERENCEID" => reference_id)
  end

  def refund_transaction(transaction, amount)
    post("METHOD" => "RefundTransaction",
         "USER" => @user,
         "PWD" => @password,
         "SIGNATURE" => @signature,
         "VERSION" => @version,
         "TRANSACTIONID" => transaction,
         "REFUNDTYPE" => "Partial",
         "AMT" => amount)
  end

  def void_transaction(authorization)
    post("METHOD" => "DoVoid",
         "AUTHORIZATIONID" => authorization)
  end

  private

  def post(params)
    response = Net::HTTP.post_form(URI.parse(get_value_of_parameter("api_url")), params)
    response.body.split("&").map { |it| URI.decode_www_form(it).first }.to_h
  end

  def get_value_of_parameter(parameter)
    @gateway_parameters.find { |param| param.name == parameter }.value
  end
end
