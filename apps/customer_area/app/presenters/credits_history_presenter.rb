class CreditsHistoryPresenter < BasePresenter
  def can_render?
    false
  end

  def path
    "events/events/credits_history"
  end
end
