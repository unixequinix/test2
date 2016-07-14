class Payments::Redsys::Payer
  def initialize(params)
    @params = params
  end

  def start(customer_order_creator, customer_credit_creator)
    notify_payment(customer_order_creator, customer_credit_creator)
  end

  def notify_payment(customer_order_creator, customer_credit_creator)
    decoded_params = decode_parameters(@params["Ds_MerchantParameters"])
    event = Event.friendly.find(@params[:event_id])
    merchant_code = event.get_parameter("payment", "redsys", "code")
    return unless decoded_params["Ds_Order"] && decoded_params["Ds_MerchantCode"] == merchant_code
    response = decoded_params["Ds_Response"]
    success = response =~ /00[0-9][0-9]|0900/
    amount = decoded_params["Ds_Amount"].to_f / 100 # last two digits are decimals
    return unless success
    order = Order.find_by(number: decoded_params["Ds_Order"])
    customer_credit_creator.save(order)
    create_payment(order, amount, decoded_params)
    order.complete!
    customer_order_creator.save(order, "card", "redsys")
    send_mail_for(order, event)
  end

  def decode_parameters(parameters)
    JSON.parse(Base64.decode64(parameters.tr("-_", "+/")))
  end

  private

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end

  def create_payment(order, amount, decoded_params)
    Payment.create!(transaction_type: decoded_params["Ds_TransactionType"],
                    card_country: decoded_params["Ds_Card_Country"],
                    paid_at: "#{decoded_params['Ds_Date']}, #{decoded_params['Ds_Hour']}",
                    order: order,
                    response_code: decoded_params["Ds_Response"],
                    authorization_code: decoded_params["Ds_AuthorisationCode"],
                    currency: decoded_params["Ds_Currency"],
                    merchant_code: decoded_params["Ds_MerchantCode"],
                    amount: amount,
                    terminal: decoded_params["Ds_Terminal"],
                    success: true,
                    payment_type: "redsys")
  end
end
