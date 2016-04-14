class Payments::PaypalNvpPayer
  def start(params, customer_order_creator, customer_credit_creator)
    @event = Event.friendly.find(params[:event_id])
    @order = Order.find(params[:order_id])
    @customer_event_profile = @order.customer_event_profile
    @gateway = @customer_event_profile.gateway_customer(EventDecorator::PAYPAL)
    @method = @gateway ? 'auto' : 'regular'
    @order.start_payment!
    charge_object = charge(params)
    return charge_object unless charge_object.success?
    create_agreement(@order, charge_object, params[:autotopup_amount]) if create_agreement?(params)
    notify_payment(charge_object, customer_order_creator, customer_credit_creator)
    charge_object
  end

  def charge(params)
    binding.pry
    get_express_checkout_details(params[:token])
    charge = do_express_checkout_payment(params[:token], params[:payer_id])
  end

  private

  def create_billing_agreement(token)
    params = {
      "METHOD" => "CreateBillingAgreement",
      "USER" => get_value_of_parameter(@event, "user"),
      "PWD" => get_value_of_parameter(@event, "password"),
      "SIGNATURE" => get_value_of_parameter(@event, "signature"),
      "VERSION" => "86",
      "TOKEN" => token
    }
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    response.body.split("&").map{|it|it.split("=")}.to_h
  end


  def get_express_checkout_details(token)
    params = {
      "METHOD" => "GetExpressCheckoutDetails",
      "TOKEN" => token
    }
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    response.body.split("&").map{|it|it.split("=")}.to_h
  end

  def do_express_checkout_payment(token, payer_id)
    params = {
      "METHOD" => "DoExpressCheckoutPayment",
      "TOKEN" => token,
      "PAYER_ID" => payer_id
    }
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    response.body.split("&").map{|it|it.split("=")}.to_h
  end

  def do_reference_transaction(amount, reference_id)
    params = {
      "METHOD" => "DoReferenceTransaction",
      "USER" => get_value_of_parameter(@event, "user"),
      "PWD" => get_value_of_parameter(@event, "password"),
      "SIGNATURE" => get_value_of_parameter(@event, "signature"),
      "VERSION" => "86",
      "AMT" => amount,
      "CURRENCYCODE" => get_value_of_parameter(@event, "currency"),
      "PAYMENTACTION" => "SALE",
      "REFERENCEID" => reference_id
    }
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    response.body.split("&").map{|it|it.split("=")}.to_h
  end

  def options(params)
    amount = @order.total_formated
    sale_options = {
      order_id: @order.number,
      amount: amount
    }
    submit_for_settlement(sale_options)
    vault_options(sale_options, @customer_event_profile.customer) if create_agreement?(params)
    send("#{@method}_payment_options", sale_options, params)
    sale_options
  end

  def notify_payment(charge, customer_order_creator, customer_credit_creator)
    transaction = charge.transaction
    return unless transaction.status == "settling"
    create_payment(@order, charge)
    customer_credit_creator.save(@order)
    customer_order_creator.save(@order)
    @order.complete!
    send_mail_for(@order, @event)
  end

  def create_agreement(_order, charge_object, autotopup_amount)
    @customer_event_profile.payment_gateway_customers
      .find_or_create_by(gateway_type: EventDecorator::PAYPAL)
      .update(token: charge_object.transaction.customer_details.id,
              agreement_accepted: true,
              autotopup_amount: autotopup_amount)
    @customer_event_profile.save
  end

  def create_agreement?(params)
    params[:accept] && !@customer_event_profile.gateway_customer(EventDecorator::PAYPAL)
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

  def create_payment(order, charge)
    transaction = charge.transaction
    Payment.create!(transaction_type: transaction.payment_instrument_type,
                    card_country: transaction.credit_card_details.country_of_issuance,
                    paid_at: Time.at(transaction.created_at),
                    last4: transaction.credit_card_details.last_4,
                    order: order,
                    response_code: transaction.processor_response_code,
                    authorization_code: transaction.processor_authorization_code,
                    currency: @event.currency,
                    merchant_code: transaction.id,
                    amount: transaction.amount.to_f,
                    success: true,
                    payment_type: "paypal")
  end
end
