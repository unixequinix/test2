Recaptcha.configure do |config|
  config.site_key  = Rails.application.secrets.recaptcha_site_key
  config.secret_key = Rails.application.secrets.recaptcha_secret_key
end

Recaptcha.configuration.skip_verify_env.push('development')
Recaptcha.configuration.skip_verify_env.push('staging')
Recaptcha.configuration.skip_verify_env.push('hotfix')
Recaptcha.configuration.skip_verify_env.push('demo')
Recaptcha.configuration.skip_verify_env.push('sandbox')
Recaptcha.configuration.skip_verify_env.push('integration')
