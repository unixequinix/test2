class Events::PaymentsController < Events::BaseController
  before_action :check_order_status!, only: [:purchase, :setup_purchase]

  def set_order_details
    @order = @current_event.orders.find(params[:order_id])
    @total = (@order.total.to_f * 100).round
  end

  def finish_payment!(order, gateway, type)
    Transactions::Base.new.portal_write(event_id: @current_event.id,
                                        station_id: @current_event.portal_station.id,
                                        type: "MoneyTransaction",
                                        transaction_origin: Transaction::ORIGINS[:portal],
                                        action: "portal_#{type}",
                                        customer_tag_uid: order.customer.active_gtag&.tag_uid,
                                        payment_method: gateway,
                                        payment_gateway: gateway,
                                        order_id: order.id,
                                        customer_id: order.customer_id,
                                        price: order.total.to_f,
                                        status_code: 0,
                                        status_message: "OK")
  end

  def check_order_status!
    @order = @current_event.orders.find(params[:order_id])
    return unless current_customer != @order.customer || @order.completed?
    flash.now[:error] = I18n.t("alerts.order_complete") if @order.completed?
    redirect_to event_url(@current_event)
  end
end
