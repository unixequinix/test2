class Dashboard
  attr_accessor :admittance, :gtag_registration, :refund, :event

  def initialize(admission)
    @admittance = admission.assigned_admittance
    @gtag_registration = admission.assigned_gtag_registration
    @refund = admission.customer.refund
    @event = admission.event
    @presenters = []
    @fee = EventParameter.find_by(event_id: @event.id, parameter_id: Parameter.find_by(category: 'refund', group: @event.refund_service, name: 'fee')).value
    @minimum = EventParameter.find_by(event_id: @event.id, parameter_id: Parameter.find_by(category: 'refund', group: @event.refund_service, name: 'minimum')).value
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
