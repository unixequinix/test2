class Api::V1::Events::BaseController < Api::BaseController
  before_action :fetch_current_event
  before_action :restrict_app_version
  before_action :check_api_open

  serialization_scope :current_event

  def render_entity(obj, date)
    response.headers["Last-Modified"] = date if date
    status = obj ? 200 : 304
    render(status: status, json: obj)
  end

  private

  def check_api_open
    head(:unauthorized) unless @current_event.open_api?
  end

  def set_modified
    @modified = request.headers["If-Modified-Since"]
  end
end
