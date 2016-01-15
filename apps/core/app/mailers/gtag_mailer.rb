class GtagMailer < ApplicationMailer
  def assigned_email(gtag_registration)
    config_parameters(gtag_registration)
    mail(to: gtag_registration.customer_event_profile.customer.email, reply_to: @event.support_email, subject: I18n.t('email.customer.gtag.assigned.subject'))
  end

  def unassigned_email(gtag_registration)
    config_parameters(gtag_registration)
    mail(to: gtag_registration.customer_event_profile.customer.email, reply_to: @event.support_email, subject: I18n.t('email.customer.gtag.unassigned.subject'))
  end

  private

  def config_parameters(gtag_registration)
    headers["X-No-Spam"] = "True"
    @name = gtag_registration.customer_event_profile.customer.name + " " + gtag_registration.customer_event_profile.customer.surname
    @gtag = gtag_registration.credentiable
    @event = gtag_registration.customer_event_profile.event
    headers['In-Reply-To'] = @event.support_email
    I18n.config.globals[:gtag] = @event.gtag_name
  end
end
