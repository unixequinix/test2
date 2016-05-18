class Events::AutotopupAgreementsController < Events::BaseController
  before_action :check_autotopup!

  def new
    payment_service = params[:payment_service]
    @order = Order.find_by_id(params[:order_id]) || autotopup_order
    @order_presenter =
      "Orders::#{payment_service.to_s.camelize}Presenter".constantize
                                                         .new(current_event, @order)
                                                         .with_params(params)
  end

  def update
    @payment_service = params[:payment_service]
    @order = OrderManager.new(Order.find(params[:id])).sanitize_order
    params[:consumer_ip_address] = request.ip
    params[:consumer_user_agent] = request.user_agent
    params[:autotopup_agreement] = true
    @form_data = "Payments::#{@payment_service.camelize}DataRetriever"
                 .constantize.new(current_event, @order).with_params(params)
    @order.start_payment!
  end

  def destroy
    @payment_gateway_customer = PaymentGatewayCustomer.find(params[:id])
    if @payment_gateway_customer.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to event_url(current_event)
    else
      flash[:error] = @payment_gateway_customer.errors.full_messages.join(". ")
      redirect_to edit_event_registrations_url(current_event)
    end
  end

  private

  # TODO: Remove from this controller
  def autotopup_order
    order = Order.new(profile: current_profile)
    order.generate_order_number!
    catalog_item = current_event.credits.standard.catalog_item
    order.order_items << OrderItem.new(
      catalog_item_id: catalog_item.id,
      amount: 1,
      total: 1
    )
    order.save
    order
  end

  def check_autotopup!
    redirect_to event_url(current_event) unless current_event.gtag_assignation? &&
                                                current_profile.active_credentials? &&
                                                current_event.agreement_acceptance? &&
                                                current_event.autotopup_payment_services.present?
  end
end
