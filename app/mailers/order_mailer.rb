class OrderMailer < ApplicationMailer
  default template_path: 'mailers/order_mailer'

  def completed_refund(refund)
    @refund = refund
    return if initialise_customer(@refund)

    apply_locale(@customer)
    headers["X-No-Spam"] = "True"
    mail(to: @customer.email, reply_to: @event.support_email, subject: t("email.refund.subject", event: @event.name))
  end

  def completed_order(order)
    @order = order
    return if initialise_customer(@order)

    apply_locale(@customer)
    headers["X-No-Spam"] = "True"
    headers["In-Reply-To"] = @event.support_email
    mail(to: @customer.email, reply_to: @event.support_email, subject: t("email.order.subject", event: @event.name))
  end

  private

  def initialise_customer(record)
    @customer = record.customer
    @name = @customer.name
    @event = record.event
    true if @customer.anonymous?
  end
end
