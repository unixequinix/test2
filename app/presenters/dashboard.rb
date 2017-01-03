class Dashboard
  attr_accessor :context, :customer, :tickets, :gtag, :event

  def initialize(customer, context)
    @context = context
    @customer = customer
    @event = customer.event
    @tickets = customer.tickets.includes(:ticket_type)
    @gtag = customer.active_gtag
    @presenters = []
  end

  def partial
    "events/events/states/event_#{@event.state}"
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
