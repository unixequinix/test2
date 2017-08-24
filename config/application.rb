require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GlownetWeb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    Figaro.load

    config.middleware.use Rack::Attack

    config.active_record.belongs_to_required_by_default = true

    # Language and encoding
    I18n.config.enforce_available_locales = true
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :es, :de, :it]
    config.i18n.fallbacks = true
    config.time_zone = "Madrid"
    config.encoding = "utf-8"

    # Paperclip
    config.paperclip_defaults = {
      storage: :s3,
      s3_protocol: :https,
      s3_region: "eu-west-1",
      s3_credentials: {
          access_key_id: Rails.application.secrets.s3_access_key_id,
          secret_access_key: Rails.application.secrets.s3_secret_access_key,
          bucket: Rails.application.secrets.s3_bucket,
          s3_host_name: Rails.application.secrets.s3_hostname
      }
    }

    # Mailer
    config.action_mailer.deliver_later_queue_name = 'low'
    config.action_mailer.preview_path = "#{Rails.root}/app/mailers/previews"
    config.action_mailer.smtp_settings = {
      address: 'smtp.mandrillapp.com',
      port: 587,
      domain: 'smtp.mandrillapp.com',
      user_name: Rails.application.secrets.smtp_username,
      password: Rails.application.secrets.smtp_password,
      authentication: 'plain',
      enable_starttls_auto: true,
      openssl_verify_mode: 'none'
    }

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end
  end
end
