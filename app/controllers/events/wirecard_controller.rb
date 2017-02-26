class Events::WirecardController < Events::PaymentsController
  before_action :set_order_details, only: [:purchase, :refund]

  def purchase
    credit_card = ActiveMerchant::Billing::CreditCard.new(permitted_params)
    response = wirecard.purchase(@total, credit_card, currency: @current_event.currency)

    if response.success?
      @order.complete!("wirecard", response.params.as_json)
      finish_payment!(@order, "wirecard")
      redirect_to customer_root_path(@current_event), notice: "Payment completed successfully."
    else
      @order.fail!("wirecard", response.params.as_json)
      redirect_to event_order_path(@current_event, @order, gateway: "wirecard"), alert: response.message
    end
  end

  def refund
    response = wirecard.refund(@total, @order.payment_data["GuWID"])

    if response.success?
      @order.cancel!(response.params.as_json)
      cancel_payment!(@order, "wirecard")
      redirect_to customer_root_path(@current_event), notice: "Order ##{@order.number} cancelled successfully."
    else
      redirect_to customer_root_path(@current_event), alert: response.message
    end
  end

  private

  def permitted_params
    params.permit(:first_name, :last_name, :number, :month, :year, :verification_value)
  end

  def wirecard
    gateway = @current_event.payment_gateways.wirecard
    ActiveMerchant::Billing::WirecardGateway.new(gateway.data.symbolize_keys)
  end
end
