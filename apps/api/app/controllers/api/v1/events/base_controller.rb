class Api::V1::Events::BaseController < Api::BaseController
  before_action :fetch_current_event
  before_filter :enable_fetcher

  private

  def enable_fetcher
    @fetcher = Multitenancy::ApiFetcher.new(current_event)
  end
end
