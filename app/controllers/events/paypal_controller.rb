class Events::PaypalController < Events::PaymentsController
  before_action :set_order_details, only: [:setup_purchase, :purchase, :refund]

  def setup_purchase
    items = @order.order_items.map do |oi|
      { name: oi.catalog_item.name, quantity: oi.amount.to_i, amount: (oi.total.to_f * 100).round }
    end

    response = paypal.setup_purchase(
      @total,
      ip: request.remote_ip,
      items: items,
      return_url: event_paypal_purchase_url(current_event, order_id: @order),
      cancel_return_url: event_order_url(current_event, @order),
      currency: current_event.currency
    )
    redirect_to paypal.redirect_url_for(response.token)
  end

  def purchase
    response = paypal.purchase(@total, payer_id: params[:PayerID], token: params[:token])

    if response.success?
      @order.complete!("paypal", response.params.as_json)
      finish_payment!(@order, "paypal", "purchase")
      redirect_to customer_root_path(current_event), notice: "Payment completed successfully."
    else
      @order.fail!("paypal", response.params.as_json)
      redirect_to event_order_path(current_event, @order, gateway: "paypal"), alert: response.message
    end
  end

  def refund
    payment_number = @order.payment_data["PaymentInfo"]["TransactionID"]
    response = paypal.refund(@total, payment_number)

    if response.success?
      @order.cancel!(response.params.as_json)
      finish_payment!(@order, "paypal", "refund")
      redirect_to customer_root_path(current_event), notice: "Order ##{@order.number} cancelled successfully."
    else
      redirect_to customer_root_path(current_event), alert: response.message
    end
  end

  private

  def paypal
    gateway = current_event.payment_gateways.paypal
    ActiveMerchant::Billing::PaypalExpressGateway.new(gateway.data.symbolize_keys)
  end
end
