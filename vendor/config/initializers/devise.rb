Devise.setup do |config|
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
  config.reconfirmable = false
  config.expire_all_remember_me_on_sign_out = false
  config.sign_out_all_scopes = false
  config.password_length =7..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete

  # Username or email
  config.authentication_keys = [ :login ]

  # config.secret_key = Rails.application.secrets.secret_key_base
  config.secret_key = '92b0f6a8ba7a3a8fa377bbe3c29a903e75eddff403c309ea15db385957bdcef743007fd4e08bbbd01048d02c9f5529b9523d6742903e42f5e3ad4255536898a4'

  # Omniauth configuration
  
  if Rails.env.development? || Rails.env.test?
    Rails.application.config.middleware.use OmniAuth::Builder do 
      provider :facebook, ENV['dev_facebook_id'], ENV['dev_facebook_secret'], callback_url: "#{Rails.application.secrets.host_url}customers/auth/facebook/callback" 
    end
  else
    config.omniauth :facebook, Rails.application.secrets.facebook_public, Rails.application.secrets.facebook_secret, callback_url: "#{Rails.application.secrets.host_url}customers/auth/facebook/callback" 
  end
  
  config.omniauth :google_oauth2, Rails.application.secrets.google_public, Rails.application.secrets.google_secret, callback_url: "#{Rails.application.secrets.host_url}/customers/auth/twitter/callback"

  config.omniauth_path_prefix = "/customers/auth"
  
end
