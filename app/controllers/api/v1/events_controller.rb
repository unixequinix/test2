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
    @current_event = scope.friendly.find_by(id: params[:event_id] || params[:id])
    # NOTE: DO NOT change the error message
    render json: { error: "Event is closed" }, status: :forbidden unless @current_event
  end

  def event_auth
    # return true if @current_user.glowball?
    # NOTE: DO NOT change the error messages
    response.headers['App-Version'] = @current_event.app_version
    render(json: { error: "This app version is no longer supported" }, status: :upgrade_required) && return unless @current_event.valid_app_version?(params[:app_version])
    render(json: { error: "API is closed" }, status: :forbidden) unless @current_event.open_devices_api?
  end
end
