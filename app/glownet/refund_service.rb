class RefundService
  def initialize(claim)
    @claim = claim
    @profile = @claim.profile
  end

  def create(params)
    params = params.slice(*Refund.column_names.map(&:to_sym))
    refund = Refund.create!(params.merge(claim_id: @claim.id))
    status_ok = %w( SUCCESS PENDING ).include? refund.status
    return false unless status_ok
    @claim.complete!
    run_transactions(refund)
    ClaimMailer.completed_email(@claim, @profile.event).deliver_later
    true
  end

  def fee
    -1 * @claim.fee.to_f
  end

  def run_transactions(refund)
    neg = (refund.amount * -1).to_f
    params = {
      credits: neg,
      refundable_credits: neg,
      credit_value: @profile.event.standard_credit_price.to_f,
      payment_method: refund.payment_solution
    }
    credit_refund_transaction(params)
    money_transaction(params, refund)
    credit_fee_transaction(params) if @claim.fee > 0
    create_customer_order
  end

  def create_customer_order
    neg = (@claim.total * -1).to_i
    order = Order.new(profile: @profile)
    order.generate_order_number!
    oi = order.order_items.create(catalog_item_id: @profile.event.credits.standard.catalog_item.id,
                                  amount: neg,
                                  total: neg * @profile.event.standard_credit_price.to_f)

    CustomerOrder.create(profile: order.profile,
                         amount: oi.amount,
                         catalog_item: oi.catalog_item,
                         origin: CustomerOrder::REFUND)
  end

  def money_transaction(params, refund)
    standard_credit = Credit.standard(@profile.event).first
    fields = {
      event_id: @profile.event.id,
      transaction_category: "money",
      transaction_type: "portal_refund",
      catalogable_id: standard_credit.catalog_item.catalogable_id,
      catalogable_type: standard_credit.catalog_item.catalogable_type,
      items_amount: params[:credits] * -1,
      price: params[:credits] * standard_credit.value.to_f,
      payment_method: "online",
      payment_gateway: refund.payment_solution,
      profile_id: @profile.id
    }
    Transactions::Base.new.portal_write(fields)
  end

  def credit_refund_transaction(params)
    params[:transaction_type] = "online_refund"
    params[:credits] = params[:credits]
    params[:refundable_credits] = params[:refundable_credits]
    params[:final_balance] = @profile.credits.to_f + params[:credits].to_f
    params[:final_refundable_balance] = @profile.refundable_credits.to_f + params[:refundable_credits].to_f
    CreditWriter.create_credit(@profile, params)
  end

  def credit_fee_transaction(params)
    params[:transaction_type] = "fee"
    params[:final_balance] = @profile.credits.to_f + params[:credits].to_f + fee
    params[:final_refundable_balance] = @profile.refundable_credits.to_f + params[:refundable_credits].to_f + fee
    params[:credits] = fee
    params[:refundable_credits] = fee
    CreditWriter.create_credit(@profile, params)
  end
end
