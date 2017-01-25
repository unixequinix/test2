class GtagMailer < ApplicationMailer
  def assigned_email(_gtag)
    config_parameters(gtag_assignment)
    apply_locale(@customer)
    subject = I18n.t("email.customer.gtag.assigned.subject")
    mail(to: @customer.email, reply_to: @event.support_email, subject: subject)
  end

  def unassigned_email(gtag)
    config_parameters(gtag)
    apply_locale(@customer)
    subject = I18n.t("email.customer.gtag.unassigned.subject")
    mail(to: @customer.email, reply_to: @event.support_email, subject: subject)
  end

  private

  def config_parameters(gtag)
    @customer = gtag.customer
    @name = "#{@customer.first_name} #{@customer.last_name}"
    @gtag = gtag
    @event = gtag.event
    headers["In-Reply-To"] = @event.support_email
    headers["X-No-Spam"] = "True"
  end
end
