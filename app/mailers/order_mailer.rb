class OrderMailer < ApplicationMailer
  def completed_refund_email(refund)
    customer = refund.customer
    @refund = refund
    @name = customer.full_name
    @event = refund.event

    apply_locale(customer)
    headers["X-No-Spam"] = "True"
    mail(to: customer.email, reply_to: @event.support_email, subject: t("email.refund.completed.subject"))
  end

  def completed_order_email(order)
    customer = order.customer
    @name = customer.full_name
    @order = order
    @event = order.event

    apply_locale(customer)
    headers["X-No-Spam"] = "True"
    headers["In-Reply-To"] = @event.support_email
    mail(to: customer.email, reply_to: @event.support_email, subject: t("email.order.completed.subject", event: @event.name))
  end
end
