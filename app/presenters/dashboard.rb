class Dashboard
  attr_accessor :admittance, :gtag_registration, :refund, :event

  def initialize(admission)
    @admittance = admission.assigned_admittance
    @gtag_registration = admission.assigned_gtag_registration
    @refund = admission.customer.refund
    @event = admission.event
    @presenters = []
  end

  def empty?
    @event.created?
  end

  def partial
    "customers/dashboards/states/event_#{@event.aasm_state}"
  end

  def build_presenter(view)
    @presenters << "#{view.camelize}Presenter".constantize.new(self)
  end

  def each_presenter
    @presenters.each do |presenter|
      yield presenter
    end
  end
end
