class BasePresenter
  attr_accessor :gtag_registration, :refund, :event, :admission

  def initialize(dashboard)
    @event = dashboard.event
    @admission = dashboard.admission
    @completed_claim = dashboard.completed_claim
    @gtag_registration = dashboard.gtag_registration
  end

  def event_url
    @event.url
  end

  def completed_claim?
    @completed_claim.present?
  end

  def admission_present?
    @admission.present?
  end

  def gtag_tag_uid
    gtag.tag_uid
  end

  def gtag_refundable_amount
    gtag_registration.refundable_amount
  end

  private

  def gtag
    @gtag_registration ? @gtag_registration.gtag : Gtag.new
  end

  def formatted_date
    Time.now.strftime('%Y-%m-%d')
  end
end
