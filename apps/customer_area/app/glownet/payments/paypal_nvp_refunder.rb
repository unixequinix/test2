class Payments::PaypalNvpRefunder
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
    refund_transaction(transaction, amount)
  end

  def refund_transaction(transaction, amount)
    params = {
      "METHOD" => "RefundTransaction",
      "USER" => get_value_of_parameter("user"),
      "PWD" => get_value_of_parameter("password"),
      "SIGNATURE" => get_value_of_parameter("signature"),
      "VERSION" => "86",
      "TRANSACTIONID" => transaction_ID
      "REFUNDTYPE" => "Full"
    }
    response = Net::HTTP.post_form(URI.parse("https://api-3t.sandbox.paypal.com/nvp"), params)
    response.body.split("&").map{|it|it.split("=")}.to_h
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
