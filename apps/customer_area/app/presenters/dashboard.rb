class Dashboard
  attr_accessor :context, :profile, :ticket_assignments, :gtag_assignment,
                :completed_claim, :event, :purchases

  def initialize(profile, context)
    @context = context
    @profile = profile
    @event = profile.event
    @ticket_assignments = profile.active_tickets_assignment
                          .includes(:credentiable, credentiable: :company_ticket_type)
    @gtag_assignment = profile.active_gtag_assignment
    @completed_claim = profile.completed_claim
    @purchases = profile.sorted_purchases(format: :hash)
    @presenters = []
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
