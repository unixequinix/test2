class CreditsHistoryPresenter < BasePresenter
  def can_render?
    @event.started? || @event.finished?
  end

  def path
    "events/events/credits_history"
  end
end
