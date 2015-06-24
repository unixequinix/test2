class BasePresenter
  attr_accessor :gtag_registration, :refund, :event, :admittance

  def initialize(dashboard)
    @event = dashboard.event
    @admittance = dashboard.admittance
    @refund = dashboard.refund
    @gtag_registration = dashboard.gtag_registration
  end

  def event_url
    @event.url
  end

  def refund_present?
    @refund.present?
  end

  def admittance_present?
    @admittance.present?
  end

  def gtag_tag_uid
    gtag.tag_uid
  end

  def gtag_credit_amount
    gtag.credit_amount
  end

  private

  def gtag
    @gtag_registration ? @gtag_registration.gtag : Gtag.new
  end

  def formatted_date
    Time.now.strftime('%Y-%m-%d')
  end
end
