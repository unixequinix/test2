class Payments::IdealPayer
  def start(params, customer_order_creator, customer_credit_creator)
    notify_payment(params, customer_order_creator, customer_credit_creator)
  end

  def notify_payment(params, customer_order_creator, customer_credit_creator)
    event = Event.friendly.find(params[:event_id])
    return unless params[:paymentState] == "SUCCESS"
    amount = params[:amount].to_f
    order = Order.find(params[:order_id])
    customer_credit_creator.save(order)
    create_payment(order, amount, params)
    order.complete!
    customer_order_creator.save(order, "card", "ideal")
    send_mail_for(order, event)
  end

  private

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end

  def create_payment(order, amount, params)
    Payment.create!(transaction_type: params[:paymentType],
                    card_country: params[:financialInstitution],
                    paid_at: Time.now,
                    order: order,
                    response_code: params[:avsResponseMessage],
                    authorization_code: params[:responseFingerprint],
                    currency: params[:currency],
                    merchant_code: nil,
                    amount: amount,
                    terminal: nil,
                    success: true,
                    payment_type: "ideal")
  end
end
