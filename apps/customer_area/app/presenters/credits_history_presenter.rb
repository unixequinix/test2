class CreditsHistoryPresenter < BasePresenter
  def can_render?
    (@event.started? || @event.finished?) && has_transactions? && @gtag_assignment.present?
  end

  def path
    "events/events/credits_history"
  end

  private

  def has_transactions?
    CreditTransaction.where(status_code: 0, profile: @profile).present?
  end
end
