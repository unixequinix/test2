class Payments::PaypalNvp::Payer < Payments::PaypalNvp::BasePayer
  def initialize(params)
    super(params)
    @method = @gateway ? "auto" : "regular"
  end

  def start(customer_order_creator, credit_writer)
    @order.start_payment!
    charge_object = charge
    return charge_object unless charge_object["ACK"] == "Success"
    create_agreement(charge_object)
    notify_payment(charge_object, customer_order_creator, credit_writer)
    charge_object
  end

  private

  def notify_payment(charge, customer_order_creator, credit_writer)
    return unless charge["ACK"] == "Success"
    @payment = create_payment(@order, charge, @method)
    credit_writer.save_order(@order, @payment_type)
    customer_order_creator.save(@order, "paypal_nvp", "paypal_nvp")
    @order.complete!
    send_mail_for(@order, @event)
  end

  def send_mail_for(order, event)
    OrderMailer.completed_email(order, event).deliver_later
  end
end
