class GtagRegistrationsPresenter
  attr_accessor :gtag_registration

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
    @gtag_registration.present? ? 'gtag_registrations' :
                                  'new_gtag_registrations'
  end

  def gtag_registrations_enabled?
    @event.gtag_registration?
  end

  def customer_has_refund?
    @refund.present?
  end

  def event_url
    @event.url
  end

  def tag_uid
    @gtag_registration.gtag.tag_uid
  end
end