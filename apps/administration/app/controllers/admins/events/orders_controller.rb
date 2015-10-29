class Admins::Events::OrdersController < Admins::Events::BaseController

  before_filter :enable_fetcher

  def index
    @q = Order.joins(:customer_event_profile)
      .where(customer_event_profiles: { event_id: current_event.id })
      .search(params[:q])
    @orders = @q.result(distinct: true).page(params[:page]).includes(:customer_event_profile, customer_event_profile: :customer)
  end

  def search
    index
    render :index
  end

  def show
    @order = Order.find(params[:id])
  end


  private

    def enable_fetcher
      @fetcher = Multitenancy::OrdersFetcher.new(current_event)
    end

end
