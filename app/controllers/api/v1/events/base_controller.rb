class Api::V1::Events::BaseController < Api::V1::BaseController
  before_action :set_event
  before_action :restrict_app_version
  before_action :check_api_open

  serialization_scope :current_event

  def render_entity(obj, date)
    response.headers["Last-Modified"] = date if date
    status = obj ? 200 : 304
    render(status: status, json: obj)
  end

  private

  def set_event
    @current_event = Event.friendly.find(params[:event_id] || params[:id])
  end

  def restrict_app_version
    head(:upgrade_required, app_version: @current_event.app_version) unless @current_event.valid_app_version?(params[:app_version])
  end

  def check_api_open
    render json: { error: "Event '#{@current_event.name}' does not have the API open" }, status: :unauthorized unless @current_event.open_api?
  end

  def set_modified
    @modified = Time.parse(request.headers["If-Modified-Since"]) if request.headers["If-Modified-Since"]
  end
end
