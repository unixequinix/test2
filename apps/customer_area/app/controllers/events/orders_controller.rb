class Events::OrdersController < Events::BaseController
  before_action :check_has_ticket!
  before_action :require_permission!

  def show
    @order = Order.includes(order_items: :preevent_product).find(params[:id])
  end

  def update
    current_order = Order.find(params[:id])
    if current_order.in_progress?
      @order = current_customer_event_profile.orders.build
      current_order.order_items.each do |order_item|
        @order.order_items << OrderItem.new(
          preevent_product_id: order_item.preevent_product.id,
          amount: order_item.amount,
          total: order_item.total)
      end
      @order.generate_order_number!
      @order.save
    else
      @order = current_order
    end
    @form_data = ("Payments::#{current_event.payment_service.camelize}DataRetriever").constantize.new(current_event, @order)
    @order.start_payment!
  end

  private

  def require_permission!
    @order = Order.find(params[:id])
    return unless current_customer_event_profile != @order.customer_event_profile || @order.completed? || @order.expired?
    flash.now[:error] = I18n.t("alerts.order_complete") if @order.completed?
    flash.now[:error] = I18n.t("alerts.order_expired") if @order.expired?
    redirect_to event_url(current_event)
  end
end
