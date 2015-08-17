class GtagMailer < ApplicationMailer
  def assigned_email(gtag_registration, event)
    config_parameters(gtag_registration, event)
    mail(to: gtag_registration.customer.email, subject: I18n.t('email.customer.gtag.assigned.subject'))
  end


  def unassigned_email(gtag_registration, event)
    config_parameters(gtag_registration, event)
    mail(to: gtag_registration.customer.email, subject: I18n.t('email.customer.gtag.unassigned.subject'))
  end

  private

  def config_parameters(gtag_registration, event)
    headers['X-No-Spam'] = 'True'
    @name = gtag_registration.customer.name + ' ' + gtag_registration.customer.surname
    @gtag = gtag_registration.gtag
    @event = event
    I18n.config.globals[:gtag] = event.gtag_name
  end
end
