class Events::PaymentsController < Events::BaseController
  before_action :check_order_status!, only: [:purchase, :setup_purchase]

  def set_order_details
    @order = @current_event.orders.find(params[:order_id])
    @total = (@order.total.to_f * 100).round
  end

  def finish_payment!(order, gateway, type)
    customer = order.customer
    atts = { payment_method: gateway, payment_gateway: gateway, order_id: order.id, price: order.total.to_f }
    MoneyTransaction.write!(@current_event, "portal_#{type}", :portal, customer, customer, atts)
  end

  def check_order_status!
    @order = @current_event.orders.find(params[:order_id])
    return unless current_customer != @order.customer || @order.completed?
    flash.now[:error] = I18n.t("alerts.order_complete") if @order.completed?
    redirect_to event_path(@current_event)
  end
end
