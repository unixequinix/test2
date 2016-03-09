class CustomerMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def reset_password_instructions_email(customer)
    config_parameters(customer)
    @reset_password_token = customer.reset_password_token
    mail(to: customer.email,
         reply_to: @event.support_email,
         subject: I18n.t("auth.mailer.reset_password_instructions.subject"))
  end

  private

  def config_parameters(customer)
    headers["X-No-Spam"] = "True"
    @name = customer.first_name + " " + customer.last_name
    @event = customer.event
  end
end
