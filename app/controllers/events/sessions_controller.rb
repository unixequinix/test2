class Events::SessionsController < Devise::SessionsController
  layout "welcome_customer"
  helper_method :current_event

  private

  def after_sign_in_path_for(resource)
    request.env["omniauth.origin"] || stored_location_for(resource) || customer_root_path(current_event)
  end

  def after_sign_out_path_for(_resource)
    customer_root_path(current_event)
  end

  def current_event
    id = params[:event_id] || params[:id]
    return false unless id
    Event.find_by_slug(id) || Event.find(id) if id
  end
end
