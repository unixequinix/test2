class ApplicationMailer < ActionMailer::Base
  layout "customer_mail"

  default from: 'Glownet <no-reply@glownet.com>',
          content_type: "multipart/mixed",
          parts_order: %w[multipart/alternative text/html text/enriched text/plain application/pdf],
          template_path: 'mailers/customer_mailer'

  def apply_locale(customer)
    I18n.locale = customer.locale
  end
end
