class DashboardPresenter
  attr_accessor :admittance, :gtag_registration, :refund, :event

  def initialize(admittance, gtag_registration, refund, event)
    @admittance = admittance
    @gtag_registration = gtag_registration
    @refund = refund
    @event = event
  end

  def can_render?
    puts "adasfasdas"
    puts @event.ticketing?
    @event.ticketing?
  end

  def admittance_present?
    @admittance.present?
  end

end