class Payments::PaypalNvpRefunder
  def initialize(payment, amount)
    @payment = payment
    @order = payment.order
    @amount = amount
    @event = @order.profile.event
    @paypal_nvp = Gateways::PaypalNvp::Transaction.new(@event)
  end

  def start
    charge_object = refund(@payment.merchant_code, @amount)
    return charge_object unless charge_object["ACK"] == "Success"
    create_payment(@order, charge_object)
    charge_object
  end

  def refund(transaction, amount)
    @paypal_nvp.refund_transaction(transaction, amount)
  end

  private

  def create_payment(order, charge)
    Payment.create!(transaction_type: "refund",
                    paid_at: charge["TIMESTAMP"],
                    order: order,
                    response_code: charge["REFUNDINFO"],
                    authorization_code: charge["CORRELATIONID"],
                    currency: charge["CURRENCYCODE"],
                    merchant_code: charge["REFUNDTRANSACTIONID"],
                    amount: charge["TOTALREFUNDEDAMT"].to_f,
                    success: true,
                    payment_type: "paypal_nvp")
  end
end
