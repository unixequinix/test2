class UserMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  layout "user_mail"

  default template_path: 'mailers/user_mailer',
          from: 'Glownet <no-reply@glownet.com>',
          content_type: "multipart/mixed",
          parts_order: %w[multipart/alternative text/html text/enriched text/plain application/pdf]

  def invite_to_event(registration)
    @registration = registration
    @event = @registration.event

    headers["X-No-Spam"] = "True"
    mail(to: registration.email, subject: "You have been invited to join #{@event.name} list of operators")
  end

  def reset_password_instructions(record, token, _opts = {})
    @name = record.username
    @token = token

    headers["X-No-Spam"] = "True"
    mail(to: record.email, subject: t("email.reset_password.subject"))
  end
end
