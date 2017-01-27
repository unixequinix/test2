class Admins::Events::OrdersController < Admins::Events::BaseController
  def index
    @orders = @current_event.orders
    authorize @orders
    @orders = @orders.page(params[:page])
  end

  def show
    @order = @current_event.orders.includes(catalog_items: :event).find(params[:id])
    authorize @order
  end
end
