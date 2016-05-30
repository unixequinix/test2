class Payments::Stripe::Payer
  def start(params, customer_order_creator, customer_credit_creator)
    @event = Event.friendly.find(params[:event_id])
    @order = Order.find(params[:order_id])
    @order.start_payment!
    charge_object = charge(params)
    return charge_object unless charge_object
    notify_payment(charge_object, customer_order_creator, customer_credit_creator)
    charge_object
  end

  def charge(params)
    amount = @order.total_formated.delete(".")
    Stripe.api_key = Rails.application.secrets.stripe_platform_secret
    begin
      charge = Stripe::Charge.create(
        amount: amount, # amount in cents, again
        currency: @event.currency,
        source: params[:stripeToken],
        description: "Payment of #{amount} #{@event.currency}",
        destination: get_event_parameter_value(@event, "stripe_account_id"),
        application_fee: get_event_parameter_value(@event, "application_fee")
      )

    rescue Stripe::CardError
      # The card has been declined
      charge
    end
    charge
  end

  def notify_payment(charge, customer_order_creator, customer_credit_creator)
    return unless charge.status == "succeeded"
    create_payment(@order, charge)
    customer_credit_creator.save(@order)
    customer_order_creator.save(@order, "card", "stripe")
    @order.complete!
    send_mail_for(@order, @event)
  end

  private

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end

  def get_event_parameter_value(event, name)
    EventParameter.find_by(event_id: event.id,
                           parameter: Parameter.where(category: "payment",
                                                      group: "stripe",
                                                      name: name)).value
  end

  def create_payment(order, charge)
    Payment.create!(transaction_type: charge.source.object,
                    card_country: charge.source.country,
                    paid_at: Time.zone.at(charge.created),
                    last4: charge.source.last4,
                    order: order,
                    response_code: charge.status,
                    authorization_code: charge.balance_transaction,
                    currency: charge.currency,
                    merchant_code: charge.balance_transaction,
                    amount: charge.amount.to_f / 100,
                    success: true,
                    payment_type: "stripe")
  end
end
