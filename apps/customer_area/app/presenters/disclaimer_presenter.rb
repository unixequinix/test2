class DisclaimerPresenter < BasePresenter
  def can_render?
    @event.created? || @event.closed?
  end

  def path
    @event.created? ? "created_disclaimer" : "closed_disclaimer"
  end
end
