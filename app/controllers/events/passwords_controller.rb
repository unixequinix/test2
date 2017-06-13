class Events::PasswordsController < Devise::PasswordsController
  before_action :set_event

  layout "customer"

  private

  def after_resetting_password_path_for(_resource)
    customer_root_path(@current_event)
  end

  def after_sending_reset_password_instructions_path_for(_resource_name)
    customer_root_path(@current_event)
  end

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
  end
end
