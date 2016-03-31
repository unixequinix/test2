require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# require railties and engines here.
require_relative "../lib/boot_inquirer"

require 'core'
BootInquirer.each_active_app do |app|
  require app.gem_name
end

module GlownetWeb
  class Application < Rails::Application

    config.eager_load_paths += ["#{config.root}/apps/core/app/models"]
    BootInquirer.each_active_app do |app|
      directory = "#{config.root}/apps/#{app.gem_name}/app/models"
      config.eager_load_paths += [directory] if File.directory?(directory)
    end

    # Locale
    I18n.config.enforce_available_locales = true
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :es, :it, :th]
    config.i18n.fallbacks = true
    config.time_zone = "Madrid"
    config.encoding = "utf-8"

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Precompile additional assets
    config.assets.precompile += %w( .svg .eot .woff .ttf )
    config.assets.precompile += %w[welcome_admin.css]
    config.assets.precompile += %w[admin.css admin.js]
    config.assets.precompile += %w[admin_mobile.css admin_mobile.js]
    config.assets.precompile += %w[customer.css customer.js]

    config.paperclip_defaults = {
      storage: :s3,
      s3_protocol: :https,
      s3_credentials: {
                        access_key_id: Rails.application.secrets.s3_access_key_id,
                        secret_access_key: Rails.application.secrets.s3_secret_access_key,
                        bucket: Rails.application.secrets.s3_bucket,
                        s3_host_name: Rails.application.secrets.s3_hostname
                      }
    }

    # Custom exception handling
    config.exceptions_app = ->(env) {
      params = env["action_dispatch.request.parameters"]
      namespace = params["controller"].split('/')[0].capitalize if params
      controller = namespace.nil? ? "ExceptionsController" : "#{namespace}::ExceptionsController"
      controller.constantize.action(:show).call(env)
    }

    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end

    # Uncomment below to disable sidekiq for all. Put in specific environment if desired.
    # config.active_job.queue_adapter = :inline
  end
end
