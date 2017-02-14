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
    params[:event_id] ||= params[:id]
    @current_event = Event.find_by(slug: params[:event_id]) || Event.find_by(id: params[:event_id])
  end
end
