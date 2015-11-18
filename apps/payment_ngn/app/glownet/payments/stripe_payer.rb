class Payments::StripePayer
  attr_reader :action_after_payment
  def initialize
    @action_after_payment = ""
  end

  def start(params)
    charge_object = charge(params)
    if charge_object
      notify_payment(params, charge_object)
      @action_after_payment = "redirect_to(success_event_order_payments_path)"
    else
      @action_after_payment = "redirect_to(error_event_order_payments_path)"
    end
  end

  def charge(params)
    event = Event.friendly.find(params[:event_id])
    token = params[:stripeToken]
    order = Order.find(params[:order_id])
    amount = order.total_stripe_formated
    Stripe.api_key = EventParameter.find_by(event_id: event.id,
      parameter_id: Parameter.find_by(
        category: "payment",
        group: "stripe",
        name: "secret_key"
      )).value
    begin
      charge = Stripe::Charge.create(
        amount: amount, # amount in cents, again
        currency: "eur",
        source: token,
        description: "Example charge"
      )
    rescue Stripe::CardError => e
      # The card has been declined
      charge = nil
    end
    return charge
  end

  def notify_payment(params,charge)
    if charge.status == "succeeded"
      order = Order.find(params[:order_id])
      credit_log = CreditLog.create(customer_event_profile_id: order.customer_event_profile.id, transaction_type: CreditLog::CREDITS_PURCHASE, amount: order.credits_total)
      payment = Payment.new(
        order: order,
        amount: (charge.amount.to_f / 100), # last two digits are decimals,
        merchant_code: charge.balance_transaction,
        currency: charge.currency,
        paid_at: charge.created,
        response_code: charge,
        success: true
      )
      payment.save!
      order.complete!
      send_mail_for(order, Event.friendly.find(params[:event_id]) )
    end
  end

  private

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end
end