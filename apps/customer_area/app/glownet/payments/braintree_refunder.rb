class Payments::BraintreeRefunder
  def initialize(payment, amount)
    @payment = payment
    @order = payment.order
    @amount = amount
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
    Payment.create!(t_type: t.payment_instrument_type,
                    card_country: t.credit_card_details.country_of_issuance,
                    paid_at: Time.at(t.created_at),
                    last4: t.credit_card_details.last_4,
                    order: order,
                    response_code: t.processor_response_code,
                    authorization_code: t.processor_authorization_code,
                    currency: order.profile.event.currency,
                    merchant_code: t.id,
                    amount: t.amount.to_f,
                    success: true,
                    payment_type: "braintree")
  end
end
