ActionMailer::Base.smtp_settings = {
  :address              => Rails.application.secrets.smtp_server,
  :port                 => Rails.application.secrets.smtp_port,
  :domain               => Rails.application.secrets.smtp_domain,
  :user_name            => Rails.application.secrets.smtp_username,
  :password             => Rails.application.secrets.smtp_password,
  :authentication       => :plain,
  :enable_starttls_auto => Rails.application.secrets.smtp_enable_starttls_auto
}