class Payments::Paypal::AutotopupPayer < Payments::Paypal::BasePayer
  include Payments::AutomaticRefundable

  def start(customer_order_creator, customer_credit_creator)
    @order.start_payment!
    charge_object = charge
    return charge_object unless charge_object.success?
    create_agreement(charge_object, @params[:autotopup_amount]) if create_agreement?
    notify_payment(charge_object, customer_order_creator, customer_credit_creator)
    automatic_refund(@payment, @order.total, @params[:payment_service_id])
    charge_object
  end

  private

  def notify_payment(charge, _customer_order_creator, _customer_credit_creator)
    return unless charge.transaction.status == "settling"
    @payment = create_payment(@order, charge)
    @order.complete!
    send_mail_for(@profile.customer)
  end

  def send_mail_for(customer)
    AgreementMailer.accepted_email(customer).deliver_later
  end
end
