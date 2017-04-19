class ApplicationMailer < ActionMailer::Base
  include AbstractController::Callbacks
  layout "customer_mail"

  default from: Rails.application.secrets.from_email,
          content_type: "multipart/mixed",
          parts_order: %w[multipart/alternative text/html text/enriched text/plain application/pdf]

  def apply_locale(customer)
    I18n.locale = customer.locale
  end
end
