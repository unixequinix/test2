class ClaimMailer < ApplicationMailer
  def completed_email(claim, event)
    customer = claim.profile.customer
    config_parameters(customer, event)
    apply_locale(customer)
    @claim = claim
    mail(to: customer.email,
         reply_to: @event.support_email,
         subject: I18n.t("email.customer.claim.completed.subject"))
  end

  def notification_email(profile, event)
    customer = profile.customer
    return unless customer.present?
    config_parameters(customer, event)
    apply_locale(customer)
    mail(to: customer.email,
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
