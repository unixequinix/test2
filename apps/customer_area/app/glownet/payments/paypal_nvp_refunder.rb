class Payments::PaypalNvpRefunder
  def initialize(payment, amount)
    @payment = payment
    @order = payment.order
    @amount = amount

    @paypal_nvp = Gateways::PaypalNvp::Transaction.new(@event)
      def refund_transaction(transaction, _amount)
  end

  def start
    charge_object = refund(@payment.merchant_code, @amount)
    return charge_object unless charge_object.success?
    create_payment(@order, charge_object)
    charge_object
  end

  def refund(transaction, amount)
    refund_transaction(transaction, amount)
  end

  private

  def create_payment(order, charge)
    transaction = charge.transaction
    Payment.create!(transaction_type: transaction.payment_instrument_type,
                    card_country: transaction.credit_card_details.country_of_issuance,
                    paid_at: Time.at(transaction.created_at),
                    last4: transaction.credit_card_details.last_4,
                    order: order,
                    response_code: transaction.processor_response_code,
                    authorization_code: transaction.processor_authorization_code,
                    currency: order.customer_event_profile.event.currency,
                    merchant_code: transaction.id,
                    amount: transaction.amount.to_f,
                    success: true,
                    payment_type: "paypal")
  end
end
