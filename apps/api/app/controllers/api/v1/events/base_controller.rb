class Api::V1::Events::BaseController < Api::BaseController
  before_action :fetch_current_event
  before_action :api_enabled
  before_filter :enable_fetcher
  serialization_scope :current_event

  def render_entities(entity)
    plural = entity.pluralize
    modified = request.headers["If-Modified-Since"]&.to_datetime

    obj = @fetcher.method(plural).call
    plural = plural.gsub("banned_", "") if plural.starts_with?("banned")
    if modified
      obj = obj.where("#{plural}.updated_at > ?", modified)
      status = obj.present? ? 200 : 304
    end

    date = obj.maximum(:updated_at)&.httpdate
    response.headers["Last-Modified"] = date if date

    status ||= 200
    render(status: status, json: obj, each_serializer: "Api::V1::#{entity.camelcase}Serializer".constantize)
  end

  def enable_fetcher
    @fetcher = Multitenancy::ApiFetcher.new(current_event)
  end

  def api_enabled
    return if current_event.devices_api?
    render(status: :unauthorized, json: :unauthorized)
  end
end
