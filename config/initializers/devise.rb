Devise.setup do |config|
  Devise::SessionsController.layout "welcome_admin"

  # Mailer config
  config.mailer_sender = 'noreply@glownet.com'
  config.mailer = 'CustomerMailer'

  # ORM Used by devise
  require 'devise/orm/active_record'

  # Devise configuration
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 11
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 3..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.secret_key = Rails.application.secrets.secret_key_base

  # Omniauth configuration
  config.omniauth_path_prefix = "/customers/auth"
  config.omniauth :facebook, Rails.application.secrets.facebook_public, Rails.application.secrets.facebook_secret, callback_url: "#{Rails.application.secrets.host_url}/customers/auth/facebook/callback"
  config.omniauth :google_oauth2, Rails.application.secrets.google_public, Rails.application.secrets.google_secret, callback_url: "#{Rails.application.secrets.host_url}/customers/auth/twitter/callback"
end
