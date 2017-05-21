class Admins::Events::OrdersController < Admins::Events::BaseController
  before_action :set_order, only: %i[show]

  def index
    @orders = @current_event.orders.order(id: :desc)
    authorize @orders
    @orders = @orders.page(params[:page])
    @counts = @current_event.orders.group(:status).count

    @graph = %w[in_progress completed cancelled failed].map do |action|
      data = OrderItem.where(order: @current_event.orders.where(status: action)).group_by_day(:created_at).sum(:amount)
      data = data.collect { |k, v| [k, v.to_i.abs] }
      { name: action, data: Hash[data] }
    end
  end

  def show
    authorize @order
  end

  private

  def set_order
    @order = @current_event.orders.includes(catalog_items: :event).find(params[:id])
  end

  def permitted_params
    params.require(:order).permit(:status)
  end
end
