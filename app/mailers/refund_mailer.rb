class RefundMailer < ApplicationMailer
  def completed_email(refund, event)
    customer = refund.customer
    @refund = refund
    @name = customer.full_name
    @event = event

    I18n.config.globals[:gtag] = @event.gtag_name
    apply_locale(customer)
    headers["X-No-Spam"] = "True"
    mail(to: customer.email, reply_to: @event.support_email, subject: I18n.t("email.customer.refund.completed.subject"))
  end
end
