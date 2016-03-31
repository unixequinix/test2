class TicketActivationsPresenter < BasePresenter
  def can_render?
    !event_started? && @customer_event_profile.active_credentials?
  end

  def event_started?
    @event.started?
  end

  def path
    "events/events/ticket_activations"
  end
end
