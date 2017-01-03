require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GlownetWeb
  class Application < Rails::Application

    #Use the IRB console instead of the Pry one
    # console do
    #   require 'irb'
    #   config.console = IRB
    # end

    config.middleware.use Rack::Deflater

    # Locale
    I18n.config.enforce_available_locales = true
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :es, :it, :th, :de, :pt]
    config.i18n.fallbacks = true
    config.time_zone = "Madrid"
    config.encoding = "utf-8"

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

    # Custom exception handling
    config.exceptions_app = ->(env) {
      params = env["action_dispatch.request.parameters"]
      namespace = params["controller"].split('/')[0].capitalize if params
      controller = namespace.nil? ? "ExceptionsController" : "#{namespace}::ExceptionsController"
      controller.constantize.action(:show).call(env)
    }

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end
  end
end
