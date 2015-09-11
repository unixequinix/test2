class DeviseMailer < Devise::Mailer
  helper :application
  default from: Rails.application.secrets.from_email,
          sender: Rails.application.secrets.from_email,
          content_type: 'multipart/mixed',
          parts_order: [ "multipart/alternative", "text/html", "text/enriched", "text/plain", "application/pdf" ]
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def reset_password_instructions(record, token, opts={})
    @event = opts[:event_id].nil? ? nil : Event.find(opts[:event_id])
    @event.nil? ? general_config_parameters : event_config_parameters(@event)
    reset_password_instructions_url(record, token, @event)
    super
  end

  def confirmation_instructions(record, token, opts={})
    @event = opts[:event_id].nil? ? nil : Event.find(opts[:event_id])
    @event.nil? ? general_config_parameters : event_config_parameters(@event)
    confirmation_instruccions_url(record, token, @event)
    super
  end


  private

  def event_config_parameters(event)
    headers['X-No-Spam'] = 'True'
    @logo_url = @event.logo.url
    @support_name = event.name
    @support_email = event.support_email
  end

  def general_config_parameters
    headers['X-No-Spam'] = 'True'
    @logo_url =
      "#{Rails.application.secrets.host_url}/assets/glownet-event-logo.png"
    @support_name = I18n.t('general_company_name')
    @support_email = I18n.t('general_support_email')
  end

  def reset_password_instructions_url(record, token, event=nil)
    @url = event.nil? ? edit_password_url(record, reset_password_token: token) : edit_event_passwords_url(event, reset_password_token: token)
  end

  def confirmation_instruccions_url(record, token, event=nil)
    @url = event.nil? ?
      confirmation_url(record, confirmation_token: token) : event_confirmations_url(event, confirmation_token: token)
  end
end