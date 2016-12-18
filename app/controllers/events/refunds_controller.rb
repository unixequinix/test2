class Events::RefundsController < Events::BaseController
  before_action :set_refund, only: [:new, :create]

  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @refund.iban = permitted_params[:iban]
    @refund.swift = permitted_params[:swift]

    if @refund.save
      credit = @current_event.credit

      # Create money transaction
      MoneyTransaction.create(
        action: "refund",
        catalog_item: credit,
        counter: current_customer.transactions.maximum(:counter).to_i + 1,
        customer: current_customer,
        event: @current_event,
        items_amount: @refund.amount.to_f * -1,
        payment_gateway: "bank_account",
        payment_method: "online",
        price: @refund.money.to_f * -1,
        status_code: 0,
        status_message: "OK",
        transaction_origin: Transaction::ORIGINS[:portal]
      )

      # Create negative online order
      current_customer.orders.create(
        gateway: "refund",
        order_items_attributes: [
          { catalog_item: credit, amount: @refund.total * -1, total: @refund.total * credit.value * -1 }
        ]
      )

      RefundMailer.completed_email(@refund, @current_event.event).deliver_later
      current_customer.active_gtag.recalculate_balance
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
    atts = { amount: amount, status: "started", fee: fee, money: money }
    @refund = current_customer.refunds.new(atts)
  end

  def permitted_params
    params.require(:refund).permit(:iban, :swift)
  end
end
