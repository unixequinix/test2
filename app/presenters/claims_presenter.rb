class ClaimsPresenter
  attr_accessor :gtag_registration, :refund

  def initialize(dashboard)
    @dashboard = dashboard
    @gtag_registration = dashboard.gtag_registration
    @refund = dashboard.refund
    @event = dashboard.event
  end

  def can_render?
    @event.refunds?
  end

  def path
    @gtag_registration.present? ? 'claims' :
                                  'claims_none'
  end

  def event_url
    @event.url
  end

  def tag_uid
    @gtag_registration.gtag.tag_uid
  end

  def refund_present?
    @refund.present?
  end

  def gtag_credit_amount
    # TODO: Demeter is crying for this :_(
    @gtag_registration.gtag.gtag_credit_log.nil? ?
      0.0 : gtag_registration.gtag.gtag_credit_log.amount
  end

  def refunds_title
    refund_present? ? I18n.t('dashboard.refunds.title') :
                      I18n.t('dashboard.without_refunds.title')
  end

  def call_to_action
    refund_present? ? I18n.t('dashboard.refunds.call_to_action', date: date) :
                      I18n.t('dashboard.without_refunds.call_to_action')
  end

  private

  def date
    Time.now.strftime("%Y-%m-%d")
  end
end
