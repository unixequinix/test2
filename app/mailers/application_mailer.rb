class ApplicationMailer < ActionMailer::Base
  layout "customer_mail"

  default from: 'Glownet <no-reply@glownet.com>',
          content_type: "multipart/mixed",
          parts_order: %w[multipart/alternative text/html text/enriched text/plain application/pdf]

  def apply_locale(customer)
    I18n.locale = customer.locale
  end
end
