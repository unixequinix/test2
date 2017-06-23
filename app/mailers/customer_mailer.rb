class CustomerMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  layout "customer_mail"

  default template_path: 'mailers/customer_mailer',
          from: 'Glownet <no-reply@glownet.com>',
          content_type: "multipart/mixed",
          parts_order: %w[multipart/alternative text/html text/enriched text/plain application/pdf]

  def welcome(record)
    @event = record.event
    @name = record.full_name

    headers["X-No-Spam"] = "True"
    I18n.locale = record.locale
    mail(to: record.email, reply_to: @event.support_email, subject: t("email.welcome.subject", event_name: @event.name))
  end

  def reset_password_instructions(record, token, _opts = {})
    @event = record.event
    @name = record.full_name
    @token = token

    headers["X-No-Spam"] = "True"
    I18n.locale = record.locale
    mail(to: record.email, reply_to: @event.support_email, subject: t("email.reset_password.subject"))
  end
end
