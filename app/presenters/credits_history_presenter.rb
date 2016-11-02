class CreditsHistoryPresenter < BasePresenter
  def can_render?
    (@event.started? || @event.finished?) &&
      transactions? && @gtag.present? && @profile.valid_balance? && @event.transactions_pdf?
  end

  def path
    "events/events/credits_history"
  end

  private

  def transactions?
    @profile.transactions.credit.status_ok.present?
  end
end
