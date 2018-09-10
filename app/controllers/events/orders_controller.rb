class Events::OrdersController < Events::EventsController
  before_action :set_order, except: %i[abstract_error]

  def abstract_error; end

  private

  def set_order
    @order = @current_event.orders.includes(order_items: :catalog_item).find(params[:id])
  end
end
