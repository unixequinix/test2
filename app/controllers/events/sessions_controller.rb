class Events::SessionsController < Devise::SessionsController
  include LanguageHelper

  before_action :resolve_locale
  before_action :set_event

  layout "customer"

  private

  def after_sign_in_path_for(resource)
    customer_root_path(resource.event)
  end

  def after_sign_out_path_for(_resource)
    event_login_path(@current_event)
  end

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
  end
end
