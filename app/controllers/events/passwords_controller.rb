class Events::PasswordsController < Devise::PasswordsController
  layout 'event'

  private

  def after_resetting_password_path_for(resource)
    event_path(current_event)
  end

  def after_sending_reset_password_instructions_path_for(resource)
    new_customer_event_session_path(current_event, password_sent: true)
  end
end
