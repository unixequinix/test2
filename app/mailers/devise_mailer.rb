class DeviseMailer < Devise::Mailer
  helper :application
  default from: Rails.application.secrets.from_email,
          content_type: 'multipart/mixed',
          parts_order: [ "multipart/alternative", "text/html", "text/enriched", "text/plain", "application/pdf" ]
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def confirmation_instructions(record, token, opts={})
    headers['X-No-Spam'] = 'True'
    # TODO Get event from the customer
    @event = Event.first
    super
  end

  def reset_password_instructions(record, token, opts={})
    headers['X-No-Spam'] = 'True'
    # TODO Get event from the customer
    @event = Event.first
    super
  end
end