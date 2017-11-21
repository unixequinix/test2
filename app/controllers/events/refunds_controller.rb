class Events::RefundsController < Events::EventsController
  before_action :set_refund, only: %i[new create]

  def new
    @bank_account = @current_event.payment_gateways.refund.bank_account.first

    if @current_event.open_refunds
      redirect_to event_path(@current_event), notice: "No refund options available" if @refunds.empty?
    else
      redirect_to event_path(@current_event)
    end
  end

  def create
    @payment_gateways = @current_event.payment_gateways.refund
    @refund = @refunds.find { |refund| refund.gateway.eql? permitted_params[:gateway] }

    redirect_to new_event_refund_path(@current_event) if @refund.blank?
    @refund.prepare_for_bank_account(permitted_params)

    if @refund.update(ip: request.remote_ip)
      refunds = @current_event.refunds.where(field_a: @refund.field_a, field_b: @refund.field_b).where.not(id: @refund.id)
      message = "has the same bank account number as #{refunds.count} other #{'refund'.pluralize(refunds.count)}"
      Alert.propagate(@current_event, @refund, message, :medium) if refunds.any?

      @refund.execute_refund_of_orders unless @refund.gateway.eql?("bank_account")
      @refund.complete!
      redirect_to customer_root_path(@current_event), notice: t("refunds.success")
    else
      redirect_to new_event_refund_path(@current_event), alert: @refund.errors.full_messages.to_sentence
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

      @current_customer.refunds.new(atts) if amount.positive? && gateway.minimum <= @current_customer.global_refundable_credits
    end.compact
  end

  def permitted_params
    params.require(:refund).permit(:field_a, :field_b, :gateway, extra_params: {})
  end
end
