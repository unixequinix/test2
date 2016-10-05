class Events::PasswordsController < Devise::PasswordsController
  layout "customer"
  helper_method :current_event

  def after_resetting_password_path_for(_resource)
    customer_root_path(current_event)
  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(_resource_name)
    customer_root_path(current_event)
  end

  def current_event
    id = params[:event_id] || params[:id]
    return false unless id
    Event.find_by_slug(id) || Event.find(id) if id
  end
end
