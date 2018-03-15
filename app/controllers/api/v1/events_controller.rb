class Api::V1::EventsController < Api::V1::BaseController
  before_action :set_event
  before_action :event_auth

  serialization_scope :current_event

  def render_entity(obj, date)
    response.headers["Last-Modified"] = date if date
    status = obj ? 200 : 304
    render(status: status, json: obj)
  end

  protected

  def set_modified
    @modified = Time.parse(request.headers["If-Modified-Since"]) if request.headers["If-Modified-Since"] # rubocop:disable Rails/TimeZone
  end

  private

  def set_event
    scope = @current_user.glowball? ? Event.all : @device.events_for_device
    @current_event = scope.friendly.find(params[:event_id] || params[:id])
  end

  def event_auth
    return true if @current_user.glowball?
    render json: { error: "This app version is no longer supported" }, status: :upgrade_required unless @current_event.valid_app_version?(params[:app_version])
    render json: { error: "API is closed for event '#{@current_event.name}'" }, status: :unauthorized unless @current_event.open_devices_api?
  end
end
