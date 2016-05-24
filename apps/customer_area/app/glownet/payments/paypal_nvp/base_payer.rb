class Payments::PaypalNvp::BasePayer
  def charge(params)
    amount = @order.total_formated
    send("#{@method}_payment", amount, params)
  end

  def regular_payment(amount, params)
    @paypal_nvp.do_express_checkout_payment(amount, params[:token], params[:payer_id])
  end

  def auto_payment(amount, _params)
    @paypal_nvp.do_reference_transaction(amount, @gateway.token)
  end

  private

  def create_agreement(charge_object, params)
    return if !enabled_autotopup? || !create_agreement?(params)
    email = @paypal_nvp.get_express_checkout_details(params[:token])["EMAIL"]
    @profile.payment_gateway_customers
            .find_or_create_by(gateway_type: EventDecorator::PAYPAL_NVP)
            .update(token: charge_object["BILLINGAGREEMENTID"],
                    agreement_accepted: true,
                    autotopup_amount: autotopup_amount(params),
                    email: email)
    @profile.save
  end

  def autotopup_amount(params)
    params[:autotopup_amount] || @order.order_items.first.amount
  end

  def create_agreement?(params)
    params[:accept] && !@profile.gateway_customer(EventDecorator::PAYPAL_NVP)
  end

  def enabled_autotopup?
    @event.get_parameter("payment", "paypal_nvp", "autotopup") == "true"
  end

  def get_event_parameter_value(event, name)
    EventParameter.find_by(event_id: event.id,
                           parameter: Parameter.where(category: "payment",
                                                      group: "paypal_nvp",
                                                      name: name)).value
  end

  def create_payment(order, charge, method)
    prefix = "PAYMENTINFO_0_" if method == "regular"
    prefix = "" if method == "auto"
    Payment.create!(transaction_type: charge["#{prefix}TRANSACTIONTYPE"],
                    paid_at: charge["TIMESTAMP"],
                    order: order,
                    response_code: charge["#{prefix}REASONCODE"],
                    authorization_code: charge["CORRELATIONID"],
                    currency: charge["#{prefix}CURRENCYCODE"],
                    merchant_code: charge["#{prefix}TRANSACTIONID"],
                    amount: charge["#{prefix}AMT"].to_f,
                    success: true,
                    payment_type: "paypal_nvp")
  end
end
