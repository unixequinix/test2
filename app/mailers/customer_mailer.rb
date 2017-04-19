class CustomerMailer < Devise::Mailer
  include Rails.application.routes.url_helpers
  layout "customer_mail"

  default from: Rails.application.secrets.from_email,
          content_type: "multipart/mixed",
          parts_order: %w[multipart/alternative text/html text/enriched text/plain application/pdf]

  def reset_password_instructions(record, token, _opts = {})
    @event = record.event
    @name = "#{record.first_name} #{record.last_name}"
    @token = token

    headers["X-No-Spam"] = "True"
    I18n.locale = record.locale
    subject = t("auth.mailer.reset_password_instructions.subject")
    mail(to: record.email, reply_to: @event.support_email, subject: subject)
  end

  def completed_refund_email(refund, event)
    customer = refund.customer
    @refund = refund
    @name = customer.full_name
    @event = event

    apply_locale(customer)
    headers["X-No-Spam"] = "True"
    mail(to: customer.email, reply_to: @event.support_email, subject: t("email.customer.refund.completed.subject"))
  end

  def completed_order_email(order, event)
    customer = order.customer
    @name = customer.full_name
    @order = order
    @event = event

    apply_locale(customer)
    headers["X-No-Spam"] = "True"
    headers["In-Reply-To"] = event.support_email
    mail(to: customer.email, reply_to: @event.support_email, subject: t("email.customer.order.completed.subject"))
  end
end
