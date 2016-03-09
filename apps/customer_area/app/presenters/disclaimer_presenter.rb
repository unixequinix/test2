class DisclaimerPresenter < BasePresenter
  def can_render?
    true
  end

  def path
    @event.created? ? "created_disclaimer" : "created_disclaimer"
  end
end
