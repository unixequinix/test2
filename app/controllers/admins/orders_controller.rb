class Admins::OrdersController < Admins::BaseController

  def index
    @q = Order.search(params[:q])
    @orders = @q.result(distinct: true).includes(:customer)
  end

  def search
    index
    render :index
  end

  def show
    @order = Order.find(params[:id])
  end

end
