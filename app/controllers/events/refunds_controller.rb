class Events::RefundsController < Events::EventsController
  before_action :set_refund, only: %i[new create]

  def new
    redirect_to event_path(@current_event), notice: "No refund options available" if @refunds.empty?
  end

  def create
    @refund = @refunds.find { |refund| refund.gateway.eql? permitted_params[:gateway] }
    @refund.prepare(permitted_params)

    if @refund.save
      @refund.execute_refund_of_orders unless @refund.gateway.eql?("bank_account")
      @refund.complete!
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
      fee = gateway.fee
      amount = @current_customer.orders.completed.where(gateway: gateway.name).sum(&:credits) - fee
      amount = @current_customer.global_refundable_credits - fee if gateway.name.eql?("bank_account")
      amount = [amount, @current_customer.global_refundable_credits - fee].min
      atts = { amount: amount, status: "started", fee: fee, gateway: gateway.name, event: @current_event }

      @current_customer.refunds.new(atts) if amount.positive?
    end.compact
  end

  def permitted_params
    params.require(:refund).permit(:field_a, :field_b, :gateway)
  end
end
