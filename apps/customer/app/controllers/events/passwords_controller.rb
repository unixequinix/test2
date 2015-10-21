class Events::PasswordsController < Devise::PasswordsController
  layout 'event'

  private

  def after_resetting_password_path_for(resource)
    event_path(id: params[:event_id])
  end

  def after_sending_reset_password_instructions_path_for(resource)
    new_customer_event_session_path(id: params[:event_id], password_sent: true)
  end
end
