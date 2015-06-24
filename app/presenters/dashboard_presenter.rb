class DashboardPresenter
  attr_accessor :admittance, :gtag_registration, :refund, :event

  def initialize(admission)
    @admittance = admission.assigned_admittance
    @gtag_registration = admission.assigned_gtag_registration
    @refund = admission.customer.refund
    @event = admission.event
    @presenters = {}
  end

  def empty?
    @event.created?
  end

  def partial
    "customers/dashboards/event_#{@event.aasm_state}"
  end

  def build_presenter(view)
    @presenters[view] = "#{view.camelize}Presenter".constantize.new(self)
  end

  def each_presenter
    @presenters.each do |view, presenter|
      yield view, presenter
    end
  end
end
