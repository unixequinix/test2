class Events::ClaimsController < Events::BaseController
  before_action :check_event_status!
  before_action :check_has_gtag!
  before_action :check_has_not_claims!
  before_action :require_permission!, only: [:create]
  before_action :enough_credits!, only: [:new, :create]

  private

  def check_event_status!
    return if current_event.claiming_started?
    flash.now[:error] = I18n.t("alerts.error")
    redirect_to event_url(current_event)
  end

  def check_has_not_claims!
    return unless current_customer_event_profile.completed_claim
    flash.now[:error] = I18n.t("alerts.claim_complete")
    redirect_to event_url(current_event)
  end

  def require_permission!
    @claim = Claim.find(params[form_name][:claim_id])
    return unless current_customer_event_profile !=
                  @claim.customer_event_profile || @claim.completed?
    flash.now[:error] = I18n.t("alerts.claim_complete")
    redirect_to event_url(current_event)
  end

  def enough_credits!
    @gtag = current_customer_event_profile.active_gtag_assignment.credentiable
    return if @gtag.refundable?(service_type)
    flash.now[:error] = I18n.t("alerts.quantity_not_refundable")
    redirect_to event_url(current_event)
  end

  def generate_claim
    @claim = Claim.create!(
      service_type: service_type,
      fee: current_event.refund_fee(service_type),
      minimum: current_event.refund_minimun(service_type),
      customer_event_profile: current_customer_event_profile,
      gtag: current_customer_event_profile.active_gtag_assignment.credentiable,
      total: current_customer_event_profile.active_gtag_assignment
              .credentiable.gtag_credit_log.amount * current_event.standard_credit_price)
    @claim.generate_claim_number!
    @claim
  end
end
