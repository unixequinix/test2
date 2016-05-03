class ClaimMailer < ApplicationMailer
  def completed_email(claim, event)
    config_parameters(claim.profile.customer, event)
    @claim = claim
    mail(to: claim.profile.customer.email,
         reply_to: @event.support_email,
         subject: I18n.t("email.customer.claim.completed.subject"))
  end

  def notification_email(profile, event)
    config_parameters(profile.customer, event)
    mail(to: profile.customer.email,
         reply_to: @event.support_email,
         subject: I18n.t("email.customer.claim.available_claim.subject"))
  end

  private

  def config_parameters(customer, event)
    headers["X-No-Spam"] = "True"
    @name = customer.first_name + " " + customer.last_name
    @event = event
    I18n.config.globals[:gtag] = @event.gtag_name
  end
end
