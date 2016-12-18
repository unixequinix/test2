class Events::PaypalController < Events::PaymentsController
  before_action :set_order_details, only: [:setup_purchase, :purchase, :refund]

  def setup_purchase # rubocop:disable Metrics/MethodLength
    items = @order.order_items.map do |oi|
      amount = (oi.catalog_item.price.to_f * 100).round
      { name: oi.catalog_item.name, description: "test", amount: amount, quantity: oi.amount.to_i }
    end

    response = paypal.setup_purchase(
      @total,
      subtotal: @total,
      shipping: 0,
      handling: 0,
      tax: 0,
      items: items,
      ip: request.remote_ip,
      return_url: event_paypal_purchase_url(@current_event, order_id: @order),
      cancel_return_url: event_order_url(@current_event, @order),
      currency: @current_event.currency
    )

    if response.success?
      redirect_to paypal.redirect_url_for(response.token)
    else
      redirect_to event_order_path(@current_event, @order, gateway: "paypal"), alert: response.message
    end
  end

  def purchase
    response = paypal.purchase(
      @total,
      payer_id: params[:PayerID],
      token: params[:token],
      currency: @current_event.currency
    )

    if response.success?
      @order.complete!("paypal", response.params.as_json)
      finish_payment!(@order, "paypal", "purchase")
      redirect_to customer_root_path(@current_event), notice: "Payment completed successfully."
    else
      @order.fail!("paypal", response.params.as_json)
      redirect_to event_order_path(@current_event, @order, gateway: "paypal"), alert: response.message
    end
  end

  def refund
    payment_number = @order.payment_data["PaymentInfo"]["TransactionID"]
    response = paypal.refund(@total, payment_number, currency: @current_event.currency)

    if response.success?
      @order.cancel!(response.params.as_json)
      finish_payment!(@order, "paypal", "refund")
      redirect_to customer_root_path(@current_event), notice: "Order ##{@order.number} cancelled successfully."
    else
      redirect_to customer_root_path(@current_event), alert: response.message
    end
  end

  private

  def paypal
    gateway = @current_event.payment_gateways.paypal
    ActiveMerchant::Billing::PaypalExpressGateway.new(gateway.data.symbolize_keys)
  end
end
