require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gspot
  class Application < Rails::Application
    config.autoload_paths +=
    %W(#{config.root}/app/services
       #{config.root}/app/presenters
       #{config.root}/app/forms)

    # Locale
    I18n.config.enforce_available_locales = true
    config.i18n.default_locale = :es
    config.i18n.available_locales = [:en, :es]
    config.time_zone = "Madrid"

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Add the fonts path
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # Precompile additional assets
    config.assets.precompile += %w( .svg .eot .woff .ttf )
    config.assets.precompile += %w[welcome_admin.css welcome_admin.js]
    config.assets.precompile += %w[admin.css admin.js]
    config.assets.precompile += %w[admin_mobile.css admin_mobile.js]

    config.paperclip_defaults = {
      storage: :s3,
      s3_protocol: :https,
      s3_credentials: { access_key_id: Rails.application.secrets.s3_access_key_id,
                        secret_access_key: Rails.application.secrets.s3_secret_access_key,
                        bucket: Rails.application.secrets.s3_bucket,
                        s3_host_name: Rails.application.secrets.s3_hostname
                      }
    }

    # Custom exception handling
    config.exceptions_app = ->(env) { ExceptionController.action(:show).call(env) }

    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end
  end
end
