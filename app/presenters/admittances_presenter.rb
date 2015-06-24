class AdmittancesPresenter
  attr_accessor :admittance

  def initialize(dashboard)
    @dashboard = dashboard
    @event = dashboard.event
    @admittance = dashboard.admittance
  end

  def can_render?
    @event.ticketing?
  end

  def path
    @admittance ? 'customers/dashboards/admittance_form' :
                  'customers/dashboards/admittance_activation'
  end

  def ticket_number
    @admittance.ticket.number
  end

  def event_started?
    @event.started?
  end
end
