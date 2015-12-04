class Admins::Events::OrdersController < Admins::Events::PaymentsBaseController

  def index
    @q = @fetcher.orders.search(params[:q])
    @orders = @q.result(distinct: true).page(params[:page]).includes(:customer_event_profile, customer_event_profile: :customer)
    @orders_count = @q.result(distinct: true).count
  end

  def search
    index
    render :index
  end

  def show
    @order = @fetcher.orders.find(params[:id])
  end

end
