class Events::AutotopupAgreementsController < Events::BaseController
  def new
    @order = autotopup_order
    @order_presenters = []
    current_event.selected_payment_services.each do |payment_service|
      @order_presenters <<
        "Orders::#{payment_service.to_s.camelize}AgreementPresenter".constantize
        .new(current_event, @order).with_params(params)
    end
  end

  def update
    @payment_service = params[:payment_service]
    @order = OrderManager.new(Order.find(params[:id])).sanitize_order
    params[:consumer_ip_address] = request.ip
    params[:consumer_user_agent] = request.user_agent
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

  def autotopup_order
    order = Order.new(profile: current_profile)
    order.generate_order_number!
    amount = 0.01
    catalog_item = current_event.credits.standard.catalog_item
    order.order_items << OrderItem.new(
      catalog_item_id: catalog_item.id,
      amount: amount,
      total: amount * catalog_item.price
    )
    order.save
    order
  end

end
