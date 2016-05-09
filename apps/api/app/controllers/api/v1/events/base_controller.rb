class Api::V1::Events::BaseController < Api::BaseController
  before_action :fetch_current_event
  before_filter :enable_fetcher

  private

  def render_entities(entity)
    plural = entity.pluralize
    modified = request.headers["If-Modified-Since"]

    obj = @fetcher.method(plural).call
    obj = obj.where("#{plural}.updated_at > ?", Time.zone.parse(modified) + 1) if modified

    response.headers["Last-Modified"] = obj.maximum(:updated_at).to_s
    render(json: obj, each_serializer: "Api::V1::#{entity.camelcase}Serializer".constantize)
  end

  def enable_fetcher
    @fetcher = Multitenancy::ApiFetcher.new(current_event)
  end
end
