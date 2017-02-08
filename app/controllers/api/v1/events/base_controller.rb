class Api::V1::Events::BaseController < Api::BaseController
  before_action :fetch_current_event
  serialization_scope :current_event

  def render_entity(obj, date)
    response.headers["Last-Modified"] = date if date
    status = obj ? 200 : 304
    render(status: status, json: obj)
  end

  private

  def set_modified
    @modified = request.headers["If-Modified-Since"]&.to_datetime
  end
end
