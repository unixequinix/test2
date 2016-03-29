class WelcomePresenter < BasePresenter
  def can_render?
    @event.gtag_assignation?
  end

  def path
    "events/events/welcome"
  end
end
