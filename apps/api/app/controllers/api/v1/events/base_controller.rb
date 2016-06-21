class Api::V1::Events::BaseController < Api::BaseController
  before_action :fetch_current_event
  before_filter :enable_fetcher
  serialization_scope :current_event

  def render_entities(entity)
    render(json: [])
  end

  def enable_fetcher
    @fetcher = Multitenancy::ApiFetcher.new(current_event)
  end
end
