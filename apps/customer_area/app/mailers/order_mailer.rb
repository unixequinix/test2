class OrderMailer < ApplicationMailer
  def completed_email(order, event)
    config_parameters(order, event)
    mail(to: order.customer_event_profile.customer.email,
         reply_to: @event.support_email,
         subject: I18n.t("email.customer.order.completed.subject"))
  end

  private

  def config_parameters(order, event)
    headers["X-No-Spam"] = "True"
    headers["In-Reply-To"] = event.support_email
    first_name = order.customer_event_profile.customer.first_name
    last_name = order.customer_event_profile.customer.last_name
    @name = [first_name, last_name].join(" ")
    @order = order
    @event = event
  end
end
