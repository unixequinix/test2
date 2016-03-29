class AutotopupPresenter < BasePresenter
  def can_render?
    @event.gtag_assignation?
  end

  def path
    "events/events/autotopup"
  end
end
