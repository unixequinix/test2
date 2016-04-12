class WelcomePresenter < BasePresenter
  def can_render?
    @event.launched? &&
      @event.gtag_assignation? &&
      !@customer_event_profile.active_credentials?
  end

  def path
    "events/events/welcome"
  end
end
