class Events::RedsysController < Events::PaymentsController
  before_action :set_order_details, only: %i[setup_purchase purchase]

  def purchase
    credit_card = ActiveMerchant::Billing::CreditCard.new(
      number: params[:card_number],
      month:  params[:exp_month],
      year:  params[:exp_year],
      verification_value:  params[:card_verification]
    )

    response = redsys.purchase(@total, credit_card, order_id: @order.number, currency: @current_event.currency)

    if response.success?
      @order.complete!("redsys", response.params.as_json)
      finish_payment!(@order, "redsys")
      redirect_to customer_root_path(@current_event), notice: "Payment completed successfully."
    else
      @order.fail!("redsys", response.params.as_json)
      redirect_to event_order_path(@current_event, @order, gateway: "redsys"), alert: response.message
    end
  end

  private

  def redsys
    gateway = @current_event.payment_gateways.redsys.first
    ActiveMerchant::Billing::RedsysGateway.new(gateway.data.merge(signature_algorithm: "sha256").symbolize_keys)
  end
end
