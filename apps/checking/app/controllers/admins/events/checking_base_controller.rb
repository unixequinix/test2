class Admins::Events::CheckingBaseController < ::Admins::Events::BaseController
  before_filter :enable_fetcher

  private

  def enable_fetcher
    @fetcher = Multitenancy::CheckingFetcher.new(current_event)
  end
end
