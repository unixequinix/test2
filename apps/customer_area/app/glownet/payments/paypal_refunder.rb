class Payments::PaypalRefunder
  def initialize(payment, amount)
    @payment = payment
    @order = payment.order
    @amount = amount

    # TODO: This has to go other place, done during hot fixing ;-)!!!!!
    @event = @order.customer_event_profile.event
    @payment_parameters = Parameter.joins(:event_parameters)
                          .where(category: "payment",
                                 group: "braintree",
                                 event_parameters: { event: @event })
                          .select("parameters.name, event_parameters.*")
    Braintree::Configuration.environment  = environment
    Braintree::Configuration.merchant_id = merchant_id
    Braintree::Configuration.public_key = public_key
    Braintree::Configuration.private_key = private_key
  end

  def start
    charge_object = refund(@payment.merchant_code, @amount)
    return charge_object unless charge_object.success?
    create_payment(@order, charge_object)
    charge_object
  end

  def refund(transaction, amount)
    Braintree::Transaction.refund(transaction, amount) rescue nil
  end

  private

  def create_payment(order, charge)
    t = charge.transaction
    Payment.create!(transaction_type: t.payment_instrument_type,
                    card_country: t.credit_card_details.country_of_issuance,
                    paid_at: Time.at(t.created_at),
                    last4: t.credit_card_details.last_4,
                    order: order,
                    response_code: t.processor_response_code,
                    authorization_code: t.processor_authorization_code,
                    currency: order.customer_event_profile.event.currency,
                    merchant_code: t.id,
                    amount: t.amount.to_f,
                    success: true,
                    payment_type: "paypal")
  end

  # TODO: Remove all these methods from here

  def environment
    get_value_of_parameter("environment")
  end

  def merchant_id
    get_value_of_parameter("merchant_id")
  end

  def public_key
    get_value_of_parameter("public_key")
  end

  def private_key
    get_value_of_parameter("private_key")
  end

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.value
  end
end
