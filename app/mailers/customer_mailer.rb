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
end
