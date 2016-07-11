class OrderMailer < ApplicationMailer
  def completed_email(order, event)
    customer = order.profile.customer

    config_parameters(order, event)
    apply_locale(customer)
    mail(to: customer.email,
         reply_to: @event.support_email,
         subject: I18n.t("email.customer.order.completed.subject"))
  end

  private

  def config_parameters(order, event)
    headers["X-No-Spam"] = "True"
    headers["In-Reply-To"] = event.support_email
    first_name = order.profile.customer.first_name
    last_name = order.profile.customer.last_name
    @name = [first_name, last_name].join(" ")
    @order = order
    @event = event
  end
end
