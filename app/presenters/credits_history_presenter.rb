class CreditsHistoryPresenter < BasePresenter
  def can_render?
    (@event.started? || @event.finished?) &&
      transactions? && @gtag.present? && @gtag.valid_balance? && @event.transactions_pdf?
  end

  def path
    "events/events/credits_history"
  end

  private

  def transactions?
    @gtag.transactions.credit.status_ok.present?
  end
end
