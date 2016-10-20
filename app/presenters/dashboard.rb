class Dashboard
  attr_accessor :context, :profile, :tickets, :gtag, :completed_claim, :event, :purchases

  def initialize(profile, context)
    @context = context
    @profile = profile
    @event = profile.event
    @tickets = profile.tickets.includes(:company_ticket_type)
    @gtag = profile.active_gtag
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
