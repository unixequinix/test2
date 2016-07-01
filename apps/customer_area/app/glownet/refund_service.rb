class RefundService
  def initialize(claim)
    @claim = claim
    @profile = @claim.profile
    @counters = Profile.counters(@profile.event)
  end

  def create(params)
    params = params.slice(*Refund.column_names.map(&:to_sym))
    refund = Refund.create!(params.merge(claim_id: @claim.id))
    status_ok = %w( SUCCESS PENDING ).include? refund.status
    return false unless status_ok
    @claim.complete!
    run_transactions(refund)
    ClaimMailer.completed_email(@claim, @profile.event).deliver_later
  end

  def fee
    -1 * @claim.fee.to_f
  end

  def run_transactions(refund)
    neg = (refund.amount * -1)
    params = {
      amount: neg, refundable_amount: neg, credit_value: @profile.event.standard_credit_price,
      payment_method: refund.payment_solution, transaction_origin: "refund",
      created_in_origin_at: Time.zone.now
    }
    credit_refund_transaction(params)
    money_transaction(params, refund)
    credit_fee_transaction(params) if @claim.fee > 0
  end

  def credit_refund_transaction(params) # rubocop:disable Metrics/AbcSize
    credits = params[:amount].to_f / params[:credit_value].to_f
    refundable_credits = params[:refundable_amount].to_f / params[:credit_value].to_f
    current_balance = @profile&.current_balance

    fields = {
      event_id: @profile.event.id,
      transaction_origin: params[:transaction_origin],
      transaction_category: "credit",
      transaction_type: "online_refund",
      credits: credits,
      credits_refundable: refundable_credits,
      credit_value: params[:credit_value].to_f,
      final_balance: current_balance&.final_balance.to_f + credits,
      final_refundable_balance: current_balance&.final_refundable_balance.to_f + refundable_credits,
      profile_id: @profile.id,
      gtag_counter: @counters[@profile.id][:gtag],
      online_counter: @counters[@profile.id][:online] + 1
    }
    Operations::Base.new.portal_write(fields)
  end

  def money_transaction(params, refund)
    standard_credit = Credit.standard(@profile.event).first
    fields = {
      event_id: @profile.event.id,
      transaction_origin: params[:transaction_origin],
      transaction_category: "money",
      transaction_type: "portal_refund",
      catalogable_id: standard_credit.catalog_item.catalogable_id,
      catalogable_type: standard_credit.catalog_item.catalogable_type,
      items_amount: params[:amount].to_f,
      price: standard_credit.value.to_f,
      payment_method: "online",
      payment_gateway: refund.payment_solution,
      profile_id: @profile.id,
      gtag_counter: @counters[@profile.id][:gtag],
      online_counter: @counters[@profile.id][:online] + 1
    }
    Operations::Base.new.portal_write(fields)
  end

  def credit_fee_transaction(params)
    fields = {
      event_id: @profile.event.id,
      transaction_origin: params[:transaction_origin],
      transaction_category: "credit",
      transaction_type: "fee",
      credits: fee,
      credits_refundable: fee,
      credit_value: params[:credit_value].to_f,
      final_balance: @profile.current_balance.final_balance.to_f + fee,
      final_refundable_balance: @profile.current_balance.final_refundable_balance.to_f + fee,
      profile_id: @profile.id,
      gtag_counter: @counters[@profile.id][:gtag],
      online_counter: @counters[@profile.id][:online] + 1
    }
    Operations::Base.new.portal_write(fields)
  end
end
