class AutotopupPresenter < BasePresenter
  def can_render?
    @event.gtag_assignation? && @profile.active_credentials? && @event.agreement_acceptance? &&
      @event.autotopup_payment_services.present? && @profile.payment_gateway_customers.blank?
  end

  def path
    "events/events/autotopup"
  end
end
