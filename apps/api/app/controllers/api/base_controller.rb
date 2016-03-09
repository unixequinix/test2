class Api::BaseController < ActionController::Metal
  include AbstractController::Callbacks
  include AbstractController::Rendering
  include ActionController::Renderers::All
  include ActionController::UrlFor
  include Rails.application.routes.url_helpers
  include ActionController::Serialization
  include ActionController::RackDelegation
  include ActionController::StrongParameters
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :null_session
  # before_action :restrict_access_with_http

  serialization_scope :view_context

  def current_event
    @current_event.decorate || Event.new.decorate
  end

  private

  def fetch_current_event
    id = params[:event_id] || params[:id]
    return false unless id
    @current_event = Event.find_by_slug(id) || Event.find(id) if id
  end
end
