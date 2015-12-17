class OrderMailer < ApplicationMailer
  def completed_email(order, event)
    config_parameters(order, event)
    mail(to: order.customer_event_profile.customer.email, reply_to: @event.support_email, subject: I18n.t("email.customer.order.completed.subject"))
  end

  private

  def config_parameters(order, event)
    headers["X-No-Spam"] = "True"
    headers["In-Reply-To"] = event.support_email
    @name = order.customer_event_profile.customer.name + " " + order.customer_event_profile.customer.surname
    @order = order
    @event = event
  end
end
