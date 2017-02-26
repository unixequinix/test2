class Events::MercadopagoController < Events::PaymentsController
  before_action :set_order_details, only: [:purchase, :refund]

  def purchase
    atts = { card_token: params[:token], brand: params[:payment_method_id] }
    response = mercadopago.purchase(@total, atts, order_id: @order.id, email: current_customer.email)

    if response.success?
      @order.complete!("mercadopago", response.params.as_json)
      finish_payment!(@order, "mercadopago")
      redirect_to customer_root_path(@current_event), notice: "Payment completed successfully."
    else
      @order.fail!("mercadopago", response.params.as_json)
      flash.now[:alert] = response.message
      redirect_to event_order_path(@current_event, @order, gateway: "mercadopago")
    end
  end

  def refund
    redirect_to(customer_root_path(@current_event), alert: "Order already cancelled") && return unless @order.completed?
    response = mercadopago.refund(@total, @order.payment_data["id"], order_id: @order.id)

    if response.success?
      @order.cancel!(response.params.as_json)
      cancel_payment!(@order, "mercadopago")
      redirect_to customer_root_path(@current_event), notice: "Order ##{@order.number} cancelled successfully."
    else
      redirect_to customer_root_path(@current_event), alert: response.message
    end
  end

  private

  def permitted_params
    params.permit(:number, :month, :year, :verification_value)
  end

  def mercadopago
    gateway = @current_event.payment_gateways.mercadopago
    ActiveMerchant::Billing::MercadopagoGateway.new(gateway.data.symbolize_keys)
  end
end
