class Admins::Events::OrdersController < Admins::Events::BaseController

  before_filter :enable_fetcher

  def index
    @q = @fetcher.orders.search(params[:q])
    @orders = @q.result(distinct: true).page(params[:page]).includes(:customer_event_profile, customer_event_profile: :customer)
  end

  def search
    index
    render :index
  end

  def show
    @order = @fetcher.orders.find(params[:id])
  end

  private

    def enable_fetcher
      @fetcher = Multitenancy::OrdersFetcher.new(current_event)
    end

end
