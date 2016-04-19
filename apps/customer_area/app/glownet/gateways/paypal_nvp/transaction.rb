class Gateways::PaypalNvp::Transaction
  def initialize(event)
    @gateway_parameters = Parameter.joins(:event_parameters)
                          .where(category: "payment",
                                 group: "paypal_nvp",
                                 event_parameters: { event: event })
                          .select("parameters.name, event_parameters.*")
    @user = get_value_of_parameter("user")
    @password = get_value_of_parameter("password")
    @signature = get_value_of_parameter("signature")
    @currency = get_value_of_parameter("currency")
    @version = "86"
    @billing_type = "MerchantInitiatedBilling"
    @billing_agreement_description =
      I18n.t("registration.autotoup_agreement.billing_agreement_description")
  end

  def set_express_checkout(amount, cancel_url, return_url)
    params = {
      "USER" => @user,
      "PWD" => @password,
      "SIGNATURE" => @signature,
      "METHOD" => "SetExpresscheckout",
      "VERSION" => @version,
      "PAYMENTREQUEST_0_PAYMENTACTION" => "AUTHORIZATION",
      "PAYMENTREQUEST_0_AMT" => amount,
      "PAYMENTREQUEST_0_CURRENCYCODE" => @currency,
      "L_BILLINGTYPE0" => @billing_type,
      "L_BILLINGAGREEMENTDESCRIPTION0" => @billing_agreement_description,
      "NOSHIPPING" => 1,
      "cancelUrl" => cancel_url,
      "returnUrl" => return_url,

    }
    post(params)
  end

  def get_express_checkout_details(token)
    params = {
      "METHOD" => "GetExpressCheckoutDetails",
      "USER" => @user,
      "PWD" => @password,
      "SIGNATURE" => @signature,
      "VERSION" => @version,
      "TOKEN" => token
    }
    post(params)
  end

  def do_express_checkout_payment(amount, token, payer_id)
    params = {
      "METHOD" => "DoExpressCheckoutPayment",
      "TOKEN" => token,
      "PAYERID" => payer_id,
      "USER" => @user,
      "PWD" => @password,
      "SIGNATURE" => @signature,
      "VERSION" => @version,
      "PAYMENTREQUEST_0_AMT" => amount,
      "PAYMENTREQUEST_0_CURRENCYCODE" => @currency,
      "PAYMENTREQUEST_0_PAYMENTACTION" => "Sale"
    }
    post(params)
  end

  def do_reference_transaction(amount, reference_id)
    params = {
      "METHOD" => "DoReferenceTransaction",
      "USER" => @user,
      "PWD" => @password,
      "SIGNATURE" => @signature,
      "VERSION" => @version,
      "AMT" => amount,
      "CURRENCYCODE" => @currency,
      "PAYMENTACTION" => "SALE",
      "REFERENCEID" => reference_id
    }
    post(params)
  end

  def refund_transaction(transaction, amount)
    params = {
      "METHOD" => "RefundTransaction",
      "USER" => @user,
      "PWD" => @password,
      "SIGNATURE" => @signature,
      "VERSION" => @version,
      "TRANSACTIONID" => transaction,
      "REFUNDTYPE" => "Partial",
      "AMT" => amount
    }
    post(params)
  end

  private

  def post(params)
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    response.body.split("&").map { |it| URI.decode_www_form(it).first }.to_h
  end

  def get_value_of_parameter(parameter)
    @gateway_parameters.find { |param| param.name == parameter }.value
  end
end
