class Admins::Events::OrdersController < Admins::Events::BaseController
  def index
    @q = @current_event.orders.search(params[:q])
    @orders = @q.result.page(params[:page])
  end

  def search
    index
    render :index
  end

  def show
    @order = @current_event.orders.includes(catalog_items: :event).find(params[:id])
  end
end
