class Admins::Events::CheckinBaseController < ::Admins::Events::BaseController
  before_filter :enable_fetcher

  private

  def enable_fetcher
    @fetcher = Multitenancy::CheckinFetcher.new(current_event)
  end
end
