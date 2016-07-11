class AgreementMailer < ApplicationMailer
  def accepted_email(customer)
    @event = customer.event
    subject = I18n.t("email.customer.agreement.accepted.subject")

    config_parameters(customer, @event)
    apply_locale(customer)
    mail(to: customer.email, reply_to: @event.support_email, subject: subject)
  end

  private

  def config_parameters(customer, event)
    headers["X-No-Spam"] = "True"
    headers["In-Reply-To"] = event.support_email
    @name = [customer.first_name, customer.last_name].join(" ")
    @event = event
  end
end
