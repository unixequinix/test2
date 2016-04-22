class Events::OrdersController < Events::BaseController
  before_action :check_has_ticket!
  before_action :require_permission!

  def show
    order = Order.includes(order_items: :catalog_item).find(params[:id])
    @order_presenters = []
    $view_context = view_context
    current_event.selected_payment_services.each do |payment_service|
      @order_presenters <<
        ("Orders::#{payment_service.to_s.camelize}Presenter").constantize
          .new(current_event, order).with_params(params)
    end
  end

  def update
    @payment_service = params[:payment_service]
    @order = OrderManager.new(Order.find(params[:id])).sanitize_order
    @form_data = ("Payments::#{@payment_service.camelize}DataRetriever")
                 .constantize.new(current_event, @order)
    @order.start_payment!
  end

  private

  def require_permission!
    @order = Order.find(params[:id])
    return unless current_profile !=
                  @order.customer_event_profile || @order.completed? || @order.expired?
    flash.now[:error] = I18n.t("alerts.order_complete") if @order.completed?
    flash.now[:error] = I18n.t("alerts.order_expired") if @order.expired?
    redirect_to event_url(current_event)
  end
end
