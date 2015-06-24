class RefundsPresenter < BasePresenter
  def can_render?
    @event.refunds? && (!@event.closed? || customer_refunded?)
  end

  def path
    @event.closed? ? 'refunds_closed' : 'refunds'
  end

  def customer_refunded?
    @gtag_registration && @refund
  end

  def call_to_action
    I18n.t('dashboard.refunds.call_to_action', date: formatted_date)
  end
end
