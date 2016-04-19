class Payments::PaypalNvpRefunder
  def initialize(payment, amount)
    @payment = payment
    @order = payment.order
    @amount = amount
    @event = @order.customer_event_profile.event
    @paypal_nvp = Gateways::PaypalNvp::Transaction.new(@event)
  end

  def start
    charge_object = refund(@.merchant_code, @amount)
    return charge_object unless charge_object.success?
    create_payment(@order, charge_object)
    charge_object
  end

  def refund(transaction, amount)
    @paypal_nvp.refund_transaction(transaction, amount)
  end

  private

  def create_payment(order, charge)
    transaction = charge.transaction

  def create_payment(order, charge)
    Payment.create!(transaction_type: charge["PAYMENTINFO_0_TRANSACTIONTYPE"],
                    paid_at: charge["TIMESTAMP"],
                    order: order,
                    response_code: charge["PAYMENTINFO_0_REASONCODE"],
                    authorization_code: charge["CORRELATIONID"],
                    currency: charge["PAYMENTINFO_0_CURRENCYCODE"],
                    merchant_code: charge["PAYMENTINFO_0_TRANSACTIONID"],
                    amount: charge["PAYMENTINFO_0_AMT"].to_f,
                    success: true,
                    payment_type: "paypal_nvp")
  end
end
