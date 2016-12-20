class TicketsInfoPresenter < BasePresenter
  def can_render?
    @event.started? || @event.finished?
  end

  def path
    "tickets_info"
  end
end
