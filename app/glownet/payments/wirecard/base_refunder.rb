class Payments::Wirecard::BaseRefunder
  attr_reader :amount

  def initialize(payment, refund_amount)
    @payment = payment
    @order = payment.order
    @event = @order.profile.event
    @amount = refund_amount - fee
    @payment_parameters = Parameter.joins(:event_parameters)
                                   .where(category: "payment", group: "wirecard", event_parameters: { event: @event })
                                   .select("parameters.name, event_parameters.*")
  end

  def start
    charge_object = refund
    return charge_object if charge_object["creditNumber"].blank?
    create_payment(@order, charge_object)
    charge_object
  end

  def fee
    @event.refund_fee("direct").to_f
  end

  def customer_id
    get_value_of_parameter("customer_id")
  end

  def currency
    @payment.currency
  end

  def language
    I18n.locale.to_s
  end

  def order_number
    @order.payments.where.not(transaction_type: "refund").first.merchant_code
  end

  def secret_key
    get_value_of_parameter("secret_key")
  end

  def shop_id
    get_value_of_parameter("shop_id")
  end

  def password
    get_value_of_parameter("password")
  end

  def get_value_of_parameter(parameter)
    @payment_parameters.find { |param| param.name == parameter }.try(:value)
  end

  def create_payment(order, charge)
    Payment.new(transaction_type: "refund",
                paid_at: Time.zone.now,
                order: order,
                response_code: charge["status"],
                authorization_code: charge["creditNumber"],
                currency: currency,
                merchant_code: customer_id,
                amount: amount,
                success: true)
  end

  def refund
    response = Net::HTTP.post_form(
      URI.parse("https://checkout.wirecard.com/seamless/backend/refund"),
      refund_parameters
    )
    response.body.split("&").map { |it| URI.decode_www_form(it).first }.to_h
  end

  def parameters
    {
      customerId: "customer_id",
      shopId: "shop_id",
      password: "password",
      secret: "secret_key",
      language: "language",
      orderNumber: "order_number",
      amount: "amount",
      currency: "currency"
    }
  end

  def request_fingerprint
    data = parameters.values.reduce("") { |a, e| a + send(e).to_s }
    digest = OpenSSL::Digest.new("sha512")
    OpenSSL::HMAC.hexdigest(digest, secret_key, data)
  end

  def refund_parameters
    params = parameters
    params.delete(:secret)
    params[:requestFingerprint] = "request_fingerprint"
    params.each_with_object({}) { |(k, v), result| result[k] = send(v) }
  end
end
