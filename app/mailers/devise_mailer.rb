class DeviseMailer < Devise::Mailer
  helper :application
  default from: Rails.application.secrets.from_email,
          content_type: 'multipart/mixed',
          parts_order: [ "multipart/alternative", "text/html", "text/enriched", "text/plain", "application/pdf" ]
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def reset_password_instructions(record, token, opts={})
    @event = record.event
    event_config_parameters(@event, opts)
    reset_password_instructions_url(record, token, @event)
    super
  end

  def confirmation_instructions(record, token, opts={})
    @event = record.event
    event_config_parameters(@event, opts)
    confirmation_instruccions_url(record, token, @event)
    super
  end


  private

  def event_config_parameters(event, opts)
    headers['X-No-Spam'] = 'True'
    opts[:reply_to] = event.support_email
    @logo_url = @event.logo.url
    @support_name = event.name
    @support_email = event.support_email
  end

  def reset_password_instructions_url(record, token, event)
    @url = edit_customer_event_password_url(event, reset_password_token: token)
  end

  def confirmation_instruccions_url(record, token, event)
    @url = customer_event_confirmation_url(event, confirmation_token: token)
  end
end