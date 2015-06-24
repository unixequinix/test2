ActionMailer::Base.smtp_settings = {
  address: Rails.application.secrets.smtp_address,
  port: Rails.application.secrets.smtp_port,
  domain: Rails.application.secrets.smtp_domain,
  user_name: Rails.application.secrets.smtp_username,
  password: Rails.application.secrets.smtp_password,
  authentication: Rails.application.secrets.authentication,
  enable_starttls_auto: Rails.application.secrets.smtp_enable_starttls_auto,
  openssl_verify_mode: Rails.application.secrets.smtp_openssl_verify_mode
}