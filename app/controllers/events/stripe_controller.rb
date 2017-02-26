class Events::StripeController < Events::PaymentsController
  before_action :set_order_details, only: [:purchase, :refund]

  def purchase
    credit_card = ActiveMerchant::Billing::CreditCard.new(permitted_params)
    response = stripe.purchase(@total, credit_card, currency: @current_event.currency)

    if response.success?
      @order.complete!("stripe", response.params.as_json)
      finish_payment!(@order, "stripe")
      redirect_to customer_root_path(@current_event), notice: "Payment completed successfully."
    else
      @order.fail!("stripe", response.params.as_json)
      redirect_to event_order_path(@current_event, @order, gateway: "stripe"), alert: response.message
    end
  end

  def refund
    redirect_to(customer_root_path(@current_event), alert: "Order already cancelled") && return unless @order.completed?
    response = stripe.refund(@total, @order.payment_data["id"])

    if response.success?
      @order.cancel!(response.params.as_json)
      cancel_payment!(@order, "stripe")
      redirect_to customer_root_path(@current_event), notice: "Order ##{@order.number} cancelled successfully."
    else
      redirect_to customer_root_path(@current_event), alert: response.message
    end
  end

  private

  def permitted_params
    params.permit(:number, :month, :year, :verification_value)
  end

  def stripe
    gateway = @current_event.payment_gateways.stripe
    ActiveMerchant::Billing::StripeGateway.new(gateway.data.symbolize_keys)
  end
end
