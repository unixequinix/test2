class Events::RefundsController < Events::EventsController
  before_action :set_refund

  def new
    redirect_to(event_path(@current_event), notice: "No refund options available") unless @current_event.open_refunds?
  end

  def create
    @refund.prepare_for_bank_account(permitted_params)

    if @refund.update(ip: request.remote_ip)
      refunds = @current_event.refunds.where(fields: @refund.fields).where.not(id: @refund.id)
      message = "has the same bank account number as #{refunds.count} other #{'refund'.pluralize(refunds.count)}"
      Alert.propagate(@current_event, @refund, message, :medium) if refunds.any?

      @refund.complete!
      redirect_to customer_root_path(@current_event), notice: t("refunds.success")
    else
      redirect_to new_event_refund_path(@current_event), alert: @refund.errors.full_messages.to_sentence
    end
  end

  private

  def set_refund
    amount = @current_customer.credits - @current_event.refund_fee.to_f
    atts = { credit_base: amount, credit_fee: @current_event.refund_fee.to_f, status: "started", gateway: "bank_account", event: @current_event }
    @refund = @current_customer.refunds.new(atts) if amount.positive? && @current_event.refund_minimum.to_f <= @current_customer.credits
  end

  def permitted_params
    params.require(:refund).permit(:gateway, fields: {})
  end
end
