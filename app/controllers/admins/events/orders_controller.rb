class Admins::Events::OrdersController < Admins::Events::BaseController

  def index
    @q = Order.search(params[:q])
    @orders = @q.result(distinct: true).page(params[:page]).includes(:customer_event_profile)
  end

  def search
    index
    render :index
  end

  def show
    @order = Order.find(params[:id])
  end

end
