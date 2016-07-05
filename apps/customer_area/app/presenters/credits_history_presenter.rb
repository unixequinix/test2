class CreditsHistoryPresenter < BasePresenter
  def can_render?
    (@event.started? || @event.finished?) &&
      transactions? &&
      @gtag_assignment.present? &&
      BalanceCalculator.new(@profile).valid_balance? &&
      @event.transactions_pdf?
  end

  def path
    "events/events/credits_history"
  end

  private

  def transactions?
    CreditTransaction.where(status_code: 0, profile: @profile).present?
  end
end
