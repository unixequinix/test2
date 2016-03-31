class AutotopupPresenter < BasePresenter
  def can_render?
    @event.gtag_assignation? && @customer_event_profile.active_credentials?
  end

  def path
    "events/events/autotopup"
  end
end
