class Payments::Paypal::Payer < Payments::Paypal::BasePayer
  def start(customer_order_creator, customer_credit_creator)
    @order.start_payment!
    charge_object = charge
    return charge_object unless charge_object.success?
    create_agreement(charge_object, @params[:autotopup_amount]) if create_agreement?
    notify_payment(charge_object, customer_order_creator, customer_credit_creator)
    charge_object
  end

  private

  def notify_payment(charge, customer_order_creator, customer_credit_creator)
    return unless charge.transaction.status == "settling"
    create_payment(@order, charge)
    customer_credit_creator.save(@order)
    customer_order_creator.save(@order, "paypal", "paypal")
    @order.complete!
    send_mail_for(@order, @event)
  end

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end
end
