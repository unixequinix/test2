class ClaimMailer < ApplicationMailer
  def completed_email(claim, event)
    config_parameters(claim, event)
    mail(to: claim.customer.email, subject: I18n.t('email.customer.claim.completed.subject'))

  end

  private

  def config_parameters(claim, event)
    headers['X-No-Spam'] = 'True'
    @name = claim.customer.name + ' ' + claim.customer.surname
    @claim = claim
    @event = event
  end
end
