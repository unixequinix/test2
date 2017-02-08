class Events::RefundsController < Events::BaseController
  before_action :set_refund, only: [:new, :create]

  def create # rubocop:disable Metrics/AbcSize
    @refund.field_a = permitted_params[:field_a]
    @refund.field_b = permitted_params[:field_b]

    @refund.validate_iban = true if @current_event.iban_enabled?

    if @refund.save
      credit = @current_event.credit
      atts = { items_amount: @refund.amount.to_f * -1, payment_gateway: "bank_account", payment_method: "online", price: @refund.money.to_f * -1 }

      MoneyTransaction.write!(@current_event, "refund", :portal, current_customer, current_customer, atts)

      # Create negative online order
      order = current_customer.build_order([[credit.id, -@refund.total]])
      order.update_attribute :gateway, "refund"
      order.complete!("bank_account", {}.as_json)

      CustomerMailer.completed_refund_email(@refund, @current_event).deliver_later
      redirect_to customer_root_path(@current_event), success: t("refunds.success")
    else
      render :new
    end
  end

  private

  def set_refund
    fee = @current_event.payment_gateways.bank_account.data["fee"].to_f
    amount = current_customer.refundable_credits - fee
    money = amount * @current_event.credit.value
    atts = { amount: amount, status: "started", fee: fee, money: money, event: @current_event }
    @refund = current_customer.refunds.new(atts)
    @refund_gateway = @current_event.payment_gateways.bank_account
  end

  def permitted_params
    params.require(:refund).permit(:field_a, :field_b)
  end
end
