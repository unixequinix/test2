class AutotopupPresenter < BasePresenter
  def can_render?
    @event.gtag_assignation? && @profile.active_credentials? && @event.agreement_acceptance? &&
      @event.autotopup_payment_services.present?
  end

  def path
    "events/events/autotopup"
  end
end
