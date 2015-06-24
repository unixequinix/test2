class RefundsPresenter
  def initialize(dashboard)
    @dashboard = dashboard
    @event = dashboard.event
    @admittance = dashboard.admittance
    @refund = dashboard.refund
    @gtag_registration = dashboard.gtag_registration
  end

  def can_render?
    @event.refunds? && (!@event.closed? || customer_refunded?)
  end

  def path
    @event.closed? ? 'refunds_closed' : 'refunds'
  end

  def event_url
    @event.url
  end

  def customer_refunded?
    @gtag_registration && @refund
  end

  def gtag_credit_amount
    # TODO: Demeter is crying for this :_(
    @gtag_registration.gtag.gtag_credit_log.nil? ?
      0.0 : gtag_registration.gtag.gtag_credit_log.amount
  end

  def call_to_action
    I18n.t('dashboard.refunds.call_to_action', date: date)
  end

  private

  def date
    Time.now.strftime("%Y-%m-%d")
  end
end
