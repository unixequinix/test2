class Dashboard
  attr_accessor :context, :customer_event_profile, :ticket_assignments, :gtag_assignment, :completed_claim, :event

  def initialize(customer_event_profile, context)
    @context = context
    @customer_event_profile = customer_event_profile
    @event = customer_event_profile.event
    @ticket_assignments = customer_event_profile.active_tickets_assignment
                  .includes(:credentiable, credentiable: :ticket_type)
    @gtag_assignment = customer_event_profile.active_gtag_assignment
    @completed_claim = customer_event_profile.completed_claim
    @presenters = []
  end

  def empty?
    @event.created?
  end

  def partial
    "events/events/states/event_#{@event.aasm_state}"
  end

  def build_presenter(view)
    @presenters << "#{view.camelize}Presenter".constantize.new(self, context)
  end

  def each_presenter
    @presenters.each do |presenter|
      yield presenter
    end
  end
end
