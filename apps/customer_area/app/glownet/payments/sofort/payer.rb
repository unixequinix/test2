class Payments::Sofort::Payer
  def initialize(params)
    @params = params
  end

  def start(customer_order_creator, credit_writer)
    notify_payment(customer_order_creator, credit_writer)
  end

  def notify_payment(customer_order_creator, credit_writer)
    event = Event.friendly.find(@params[:event_id])
    return unless @params[:paymentState] == "SUCCESS"
    amount = @params[:amount].to_f
    order = Order.find(@params[:order_id])
    credit_writer.save_order(order)
    create_payment(order, amount)
    order.complete!
    customer_order_creator.save(order, "card", "sofort")
    I18n.locale = @params[:language]
    send_mail_for(order, event)
  end

  private

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end

  def create_payment(order, amount)
    Payment.create!(transaction_type: @params[:paymentType],
                    card_country: @params[:senderBankName],
                    paid_at: Time.zone.now,
                    order: order,
                    response_code: @params[:avsResponseMessage],
                    authorization_code: @params[:responseFingerprint],
                    currency: @params[:currency],
                    merchant_code: @params[:orderNumber],
                    amount: amount,
                    terminal: nil,
                    success: true,
                    payment_type: "sofort")
  end
end
