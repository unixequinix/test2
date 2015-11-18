class Payments::StripePayer

  def start(params)
    charge_object = charge(params)
    notify_payment(params, charge_object)
  end

  def charge(params)
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    token = params[:stripeToken]
    event = Event.friendly.find(params[:event_id])
    order = Order.find(params[:order_id])
    amount = order.total_stripe_formated
    begin
      charge = Stripe::Charge.create(
        amount: amount, # amount in cents, again
        currency: "eur",
        source: token,
        description: "Example charge"
      )
    rescue Stripe::CardError => e
      # The card has been declined

      #doesn't work, move this redirection
      redirect_to error_event_order_payments_url(event, order)
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

  def action_after_payment
    # this method will be evaluated in the controller
    "redirect_to(success_event_order_payments_path)"
  end

  private

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end
end