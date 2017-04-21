class Events::RefundsController < Events::EventsController
  before_action :set_refund, only: %i[new create]

  def new
    redirect_to event_path(@current_event), notice: "No refund options available" if @refunds.empty?
  end

  def create # rubocop:disable Metrics/AbcSize
    @refund = @refunds.find { |refund| refund.gateway.eql? permitted_params[:gateway] }
    @refund.prepare(permitted_params)

    if @refund.save
      @refund.execute_refund_of_orders unless @refund.gateway.eql?("bank_account")

      total = @refund.total.to_f * -1
      atts = { items_amount: total, payment_gateway: @refund.gateway, payment_method: "online", price: total }
      MoneyTransaction.write!(@current_event, "refund", :portal, current_customer, current_customer, atts)

      # Create negative online order (to be replaced by tasks/transactions or start downloading refunds)
      current_customer.build_order([[@current_event.credit.id, -@refund.total]]).complete!("refund", {}.as_json)

      CustomerMailer.completed_refund_email(@refund, @current_event).deliver_later
      redirect_to customer_root_path(@current_event), notice: t("refunds.success")
    else
      @payment_gateways = @current_event.payment_gateways.refund
      flash.now[:error] = @refund.errors.full_messages.to_sentence
      render :new
    end
  end

  private

  def set_refund
    @refunds = @current_event.payment_gateways.order(:id).refund.map do |gateway|
      fee = gateway.fee.to_f
      amount = current_customer.orders.completed.where(gateway: gateway.name).sum(&:credits) - fee.to_f
      amount = current_customer.global_refundable_credits - fee.to_f if gateway.name.eql?("bank_account")
      amount = [amount, current_customer.global_refundable_credits - fee.to_f].min
      money = amount * @current_event.credit.value
      atts = { amount: amount, status: "started", fee: fee, money: money, gateway: gateway.name, event: @current_event }

      current_customer.refunds.new(atts) if amount.positive?
    end.compact
  end

  def permitted_params
    params.require(:refund).permit(:field_a, :field_b, :gateway)
  end
end
