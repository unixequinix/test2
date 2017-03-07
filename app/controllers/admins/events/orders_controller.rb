class Admins::Events::OrdersController < Admins::Events::BaseController
  def index
    @orders = @current_event.orders.order(id: :desc)
    authorize @orders
    @orders = @orders.page(params[:page])
    @counts = @current_event.orders.group(:status).count
  end

  def show
    @order = @current_event.orders.includes(catalog_items: :event).find(params[:id])
    authorize @order
  end
end
