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
    id = current_admin.slug if current_admin&.promoter? || current_admin&.customer_service?
    return false unless id
    @current_event = Event.find_by(slug: id) || Event.find_by(id: id)
  end
end
