ActionMailer::Base.smtp_settings = {
  :address              => Rails.application.secrets.smtp_server,
  :port                 => 587,
  :domain               => Rails.application.secrets.smtp_url,
  :user_name            => Rails.application.secrets.mail_username,
  :password             => Rails.application.secrets.mail_password,
  :authentication       => :plain,
  :enable_starttls_auto => true
}