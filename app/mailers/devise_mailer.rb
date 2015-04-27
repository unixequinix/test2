class DeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def confirmation_instructions(record, token, opts={})
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/" + record.class.name.underscore + "-logo.png")
    super
  end

  def reset_password_instructions(record, token, opts={})
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/" + record.class.name.underscore + "-logo.png")
    super
  end
end