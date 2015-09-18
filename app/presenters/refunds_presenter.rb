class RefundsPresenter < BasePresenter
  def can_render?
    @gtag_registration && @event.refunds? && (!@event.closed? || completed_claim?)
  end

  def path
    @event.closed? ? 'refunds_closed' : 'refunds'
  end

  def gtag_credit_amount
    "#{@gtag_registration.refundable_amount} #{I18n.t('currency_symbol')}"
  end

  def call_to_action
    I18n.t('dashboard.refunds.call_to_action', date: formatted_date)
  end
end
