class ClaimMailer < ApplicationMailer
  def completed_email(claim, event)
    config_parameters(claim.customer, event)
    @claim = claim
    mail(to: claim.customer.email, subject: I18n.t('email.customer.claim.completed.subject'))
  end

  def notification_email(customer, event)
    config_parameters(customer, event)
    mail(to: customer.email, subject: I18n.t('email.customer.claim.available_claim.subject'))
  end

  private

  def config_parameters(customer, event)
    headers['X-No-Spam'] = 'True'
    @name = customer.name + ' ' + customer.surname
    @event = event
    I18n.config.globals[:gtag] = event.gtag_name
  end
end
