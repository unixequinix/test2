class Events::AutotopupAgreementsController < Events::BaseController
  def new
    payment_service = params[:payment_service]
    @order = autotopup_order
    @order_presenter = "Orders::#{payment_service.to_s.camelize}Presenter".constantize
      .new(current_event, @order).with_params(params)
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
    amount = 0.01
    catalog_item = current_event.credits.standard.catalog_item
    order.order_items << OrderItem.new(
      catalog_item_id: catalog_item.id,
      amount: 1,
      total: 0.01
    )
    order.save
    order
  end

end
