class Events::ClaimsController < Events::BaseController
  before_action :check_has_gtag!
  before_action :require_permission!, only: [:create]
  before_action :enough_credits!, only: [:new, :create]

  private

  def require_permission!
    @claim = Claim.find(params[form_name][:claim_id])
    return unless current_profile != @claim.profile || @claim.completed?
    flash.now[:error] = I18n.t("alerts.claim_complete")
    redirect_to event_url(current_event)
  end

  def enough_credits!
    return if current_profile.refundable?(service_type)
    flash.now[:error] = I18n.t("alerts.quantity_not_refundable")
    redirect_to event_url(current_event)
  end

  def generate_claim
    @claim = Claim.new(
      service_type: service_type,
      fee: current_event.refund_fee(service_type),
      minimum: current_event.refund_minimun(service_type),
      profile: current_profile,
      gtag: current_profile.active_gtag,
      total: current_profile.refundable_money
    )
    @claim.generate_claim_number!
    @claim.save!
    @claim
  end
end