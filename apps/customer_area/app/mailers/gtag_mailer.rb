class GtagMailer < ApplicationMailer
  def assigned_email(gtag_assignment)
    config_parameters(gtag_assignment)
    subject = I18n.t("email.customer.gtag.assigned.subject")
    mail(to: @customer.email, reply_to: @event.support_email, subject: subject)
  end

  def unassigned_email(gtag_assignment)
    config_parameters(gtag_assignment)
    subject = I18n.t("email.customer.gtag.unassigned.subject")
    mail(to: @customer.email, reply_to: @event.support_email, subject: subject)
  end

  private

  def config_parameters(gtag_assignment)
    @customer = gtag_assignment.profile.customer
    @name = "#{@customer.first_name} #{@customer.last_name}"
    @gtag = gtag_assignment.credentiable
    @event = gtag_assignment.profile.event
    headers["In-Reply-To"] = @event.support_email
    headers["X-No-Spam"] = "True"
    I18n.config.globals[:gtag] = @event.gtag_name.capitalize
  end
end
