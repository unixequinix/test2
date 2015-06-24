class CreditsPresenter
  def initialize(dashboard)
    @dashboard = dashboard
    @event = dashboard.event
    @admittance = dashboard.admittance
    @customer = fetch_customer
  end

  def can_render?
    @event.ticketing?
  end

  def path
    'credits'
  end

  def admittance_present?
    @admittance.present?
  end

  def credit_sum
    @customer.credit_logs.sum(:amount)
  end

  private

  def fetch_customer
    @admittance ? @admittance.admission.customer : Customer.new
  end
end
