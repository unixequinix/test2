class OrderMailer < ApplicationMailer
  default template_path: 'mailers/order_mailer'

  def completed_refund(refund)
    @refund = refund
    customer = @refund.customer
    @name = customer.full_name
    @event = @refund.event

    apply_locale(customer)
    headers["X-No-Spam"] = "True"
    mail(to: customer.email, reply_to: @event.support_email, subject: t("email.refund.subject", event: @event.name))
  end

  def completed_order(order)
    customer = order.customer
    @name = customer.full_name
    @order = order
    @event = order.event

    apply_locale(customer)
    headers["X-No-Spam"] = "True"
    headers["In-Reply-To"] = @event.support_email
    mail(to: customer.email, reply_to: @event.support_email, subject: t("email.order.subject", event: @event.name))
  end
end
