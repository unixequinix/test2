class RefundsPresenter < BasePresenter
  def can_render?
    @event.refunds? &&  (!@event.closed? || completed_claim?) && @profile.active_credentials?
  end

  def path
    @event.closed? ? "refunds_closed" : "refunds"
  end

  def gtag_credit_amount
    "#{@gtag_assignment.credentiable.refundable_amount} #{@event.currency}"
  end

  def call_to_action
    I18n.t("dashboard.refunds.call_to_action", date: formatted_date)
  end
end
