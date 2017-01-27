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
    params[:event_id] ||= params[:id]
    @current_event = Event.find_by(slug: params[:event_id]) || Event.find_by(id: params[:event_id])
  end
end
