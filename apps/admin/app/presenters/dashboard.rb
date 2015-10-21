class Dashboard
  attr_accessor :customer_event_profile, :admissions, :gtag_registration, :completed_claim, :event

  def initialize(customer_event_profile)
    @customer_event_profile = customer_event_profile
    @event = customer_event_profile.event
    @admissions = customer_event_profile.assigned_admissions
                                        .includes(:ticket, ticket: :ticket_type)
    @gtag_registration = customer_event_profile.assigned_gtag_registration
    @completed_claim = customer_event_profile.completed_claim
    @fee = @event.get_parameter('refund', @event.refund_service, 'fee')
    @minimum = @event.get_parameter('refund', @event.refund_service, 'minimum')
    @presenters = []
  end

  def empty?
    @event.created?
  end

  def partial
    "events/events/states/event_#{@event.aasm_state}"
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
