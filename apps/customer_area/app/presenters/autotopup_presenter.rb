class AutotopupPresenter < BasePresenter
  def can_render?
    @event.gtag_assignation? && @profile.active_credentials? && @event.agreement_acceptance? &&
      @event.selected_autotopup_payment_services.present?
  end

  def path
    "events/events/autotopup"
  end
end
