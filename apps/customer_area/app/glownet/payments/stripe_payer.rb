class Payments::StripePayer
  attr_reader :action_after_payment

  def initialize
    @action_after_payment = ""
  end

  def start(params, customer_order_creator)
    @customer_order_creator = customer_order_creator
    charge_object = charge(params)
    if charge_object
      notify_payment(params, charge_object)
      @action_after_payment = "redirect_to(success_event_order_payments_path)"
      customer_order_creator.save(Order.find(params[:order_id]))
    else
      @action_after_payment = "redirect_to(error_event_order_payments_path)"
    end
  end

  def charge(params)
    event = Event.friendly.find(params[:event_id])
    amount = Order.find(params[:order_id]).total_stripe_formated
    Stripe.api_key = Rails.application.secrets.stripe_platform_secret
    begin
      charge = Stripe::Charge.create(
        amount: amount, # amount in cents, again
        currency: event.currency,
        source: params[:stripeToken],
        description: "Payment of #{amount} #{event.currency}",
        destination: get_event_parameter_value(event, "stripe_account_id"))

    rescue Stripe::CardError
      # The card has been declined
      charge = nil
    end
    charge
  end

  def notify_payment(params, charge)
    return unless charge.status == "succeeded"
    order = Order.find(params[:order_id])
    create_log(order)
    create_payment(order, charge)
    order.complete!
    send_mail_for(order, Event.friendly.find(params[:event_id]))
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

  def create_log(order)
    CustomerCreditOnlineCreator.new(customer_event_profile: order.customer_event_profile,
                                    transaction_source: CustomerCredit::CREDITS_PURCHASE,
                                    amount: order.credits_total,
                                    payment_method: "none",
                                    money_payed: order.total
                                   ).save
  end

  def create_payment(order, charge)
    Payment.create!(transaction_type: charge.source.object,
                    card_country: charge.source.country,
                    paid_at: Time.at(charge.created),
                    last4: charge.source.last4,
                    order: order,
                    response_code: charge.status,
                    authorization_code: charge.balance_transaction,
                    currency: charge.currency,
                    merchant_code: charge.balance_transaction,
                    amount: (charge.amount.to_f / 100), # last two digits are decimals,
                    success: true,
                    payment_type: "stripe")
  end
end
