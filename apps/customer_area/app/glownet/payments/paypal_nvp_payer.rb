class Payments::PaypalNvpPayer
  def start(params, customer_order_creator, customer_credit_creator)
    notify_payment(params, customer_order_creator, customer_credit_creator)
  end

  def notify_payment(params, customer_order_creator, customer_credit_creator)
    event = Event.friendly.find(params[:event_id])
    post_request_billing_agreement
    order = Order.find_by(number: params[:Ds_Order])
    customer_credit_creator.save(order)
    create_payment(order, amount, params)
    order.complete!
    customer_order_creator.save(order)
    send_mail_for(order, event)
  end

  private

  def post_request_billing_agreement
    billing_token = post_request
    current_profile = CustomerEventProfile.first
    Autotopup::PaypalNvpAgreement.create(billing_token, current_profile, 50)
  end

  def post_request
    params = {
      "USER" => user,
      "PWD" => pwd,
      "SIGNATURE" => signature,
      "METHOD" => method,
      "VERSION" => version,
      "TOKEN" => token
    }
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    hash_response = response.body.split("&").map{|it|it.split("=")}.to_h
    hash_response["BILLINGAGREEMENTID"].gsub("%2d", "-")
  end

  def user
    "payments-facilitator_api1.glownet.com"
  end

  def pwd
    "GDSHHDFJ7KEBHVRB"
  end

  def signature
    "AFcWxV21C7fd0v3bYYYRCpSSRl31A4i6SeDVCt6M9xT2Cg08xXvNmpwK"
  end

  def method
    "CreateBillingAgreement"
  end

  def version
    86
  end

  def token
    print "Write token: "
    gets.chomp
  end

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end

  def create_payment(order, amount, params)
    Payment.create!(transaction_type: params[:Ds_TransactionType],
                    card_country: params[:Ds_Card_Country],
                    paid_at: "#{params[:Ds_Date]}, #{params[:Ds_Hour]}",
                    order: order,
                    response_code: params[:Ds_Response],
                    authorization_code: params[:Ds_AuthorisationCode],
                    currency: params[:Ds_Currency],
                    merchant_code: params[:Ds_MerchantCode],
                    amount: amount,
                    terminal: params[:Ds_Terminal],
                    success: true,
                    payment_type: "redsys")
  end
end
