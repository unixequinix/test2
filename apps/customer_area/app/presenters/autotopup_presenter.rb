class AutotopupPresenter < BasePresenter
  def can_render?
    @event.gtag_assignation? && @profile.active_credentials?
  end

  def path
    "events/events/autotopup"
  end
end
