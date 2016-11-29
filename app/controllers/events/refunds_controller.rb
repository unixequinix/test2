class Events::RefundsController < Events::BaseController
  def new
    @refund = current_customer.refunds.new
  end

  def create
    fee = current_event.payment_gateways.bank_account.data[:fee].to_f
    amount = current_customer.refundable_credits - fee
    atts = { amount: amount, status: "started", fee: fee }
    @refund = current_customer.refunds.new(permitted_params.merge(atts))

    if @refund.save
      fee_transaction(@refund)
      credit_transaction(@refund)
      money_transaction(@refund)
      redirect_to customer_root_path(current_event), success: t("dashboard.refunds.success")
    else
      render :new
    end
  end

  private

  def money_transaction(refund)
    credit = current_event.credit
    amount = refund.amount.to_f * -1
    Transactions::Base.new.portal_write(
      event_id: current_event.id,
      catalog_item_id: credit.id,
      customer_id: current_customer.id,
      type: "MoneyTransaction",
      action: "online_refund",
      payment_method: "online",
      payment_gateway: "bank_account",
      items_amount: amount,
      price: amount * credit.value.to_f
    )
  end

  def permitted_params
    params.require(:refund).permit(:iban, :swift)
  end
end
