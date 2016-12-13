class OrderMailer < ApplicationMailer
  def completed_email(order, event)
    customer = order.customer
    @name = customer.full_name
    @order = order
    @event = event

    apply_locale(customer)
    headers["X-No-Spam"] = "True"
    headers["In-Reply-To"] = event.support_email
    mail(to: customer.email, reply_to: @event.support_email, subject: I18n.t("email.customer.order.completed.subject"))
  end
end
