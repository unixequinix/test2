class Payments::PaypalNvpPayer
  def start(params, customer_order_creator, customer_credit_creator)
    @event = Event.friendly.find(params[:event_id])
    @order = Order.find(params[:order_id])
    @paypal_nvp = Gateways::PaypalNvp::Transaction.new(@event)
    @profile = @order.profile
    @gateway = @profile.gateway_customer(EventDecorator::PAYPAL_NVP)
    @method = @gateway ? "auto" : "regular"
    @order.start_payment!
    charge_object = charge(params)
    return charge_object unless charge_object["ACK"] == "Success"
    email = @paypal_nvp.get_express_checkout_details(params[:token])["EMAIL"]
    create_agreement(charge_object, params[:autotopup_amount], email) if create_agreement?(params)
    notify_payment(charge_object, customer_order_creator, customer_credit_creator)
    charge_object
  end

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

  def notify_payment(charge, customer_order_creator, customer_credit_creator)
    return unless charge["ACK"] == "Success"
    create_payment(@order, charge, @method)
    customer_credit_creator.save(@order)
    customer_order_creator.save(@order, "paypal_nvp", "paypal_nvp")
    @order.complete!
    send_mail_for(@order, @event)
  end

  def create_agreement(charge_object, autotopup_amount, email)
    @profile.payment_gateway_customers
      .find_or_create_by(gateway_type: EventDecorator::PAYPAL_NVP)
      .update(token: charge_object["BILLINGAGREEMENTID"],
              agreement_accepted: true,
              autotopup_amount: autotopup_amount,
              email: email)
    @profile.save
  end

  def create_agreement?(params)
    params[:accept] && !@profile.gateway_customer(EventDecorator::PAYPAL_NVP)
  end

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
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
