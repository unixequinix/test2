class Payments::PaypalNvp::AgreementPayer
  def initialize(params)
    super(params)
    @method = @gateway ? "auto" : "regular"
  end

  def start(customer_order_creator, credit_writer)
    @order.start_payment!
    charge_object = charge
    return charge_object unless charge_object["ACK"] == "Success"
    email = @paypal_nvp.get_express_checkout_details(@params[:token])["EMAIL"]
    create_agreement(charge_object, @params[:autotopup_amount], email) if create_agreement?(@params)
    notify_payment(charge_object, customer_order_creator, credit_writer)
    charge_object
  end

  def charge
    amount = @order.total_formated
    send("#{@method}_payment", amount)
  end

  def regular_payment(amount)
    @paypal_nvp.do_express_checkout_payment(amount, @params[:token], @params[:payer_id])
  end

  def auto_payment(amount)
    @paypal_nvp.do_reference_transaction(amount, @gateway.token)
  end

  private

  def notify_payment(charge, customer_order_creator, credit_writer)
    return unless charge["ACK"] == "Success"
    create_payment(@order, charge, @method)
    credit_writer.save_order(@order)
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

  def create_agreement?
    @params[:accept] && !@profile.gateway_customer(EventDecorator::PAYPAL_NVP)
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
