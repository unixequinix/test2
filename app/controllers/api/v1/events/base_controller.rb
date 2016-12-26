class Api::V1::Events::BaseController < Api::BaseController
  before_action :fetch_current_event
  before_action :api_enabled
  serialization_scope :current_event

  def render_entity(obj, date)
    response.headers["Last-Modified"] = date if date
    status = obj ? 200 : 304
    render(status: status, json: obj)
  end

  def render_200(obj)
    ActiveModelSerializers::Adapter.create(obj).to_json
    render(status: 200, json: obj)
  end

  def api_enabled
    return unless current_event
    return unless current_event.finished?
    render(status: :unauthorized, json: :unauthorized)
  end

  private

  def set_modified
    @modified = request.headers["If-Modified-Since"]&.to_datetime
  end
end
