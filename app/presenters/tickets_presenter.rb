class TicketsPresenter < BasePresenter
  def can_render?
    !event_started? && @customer.active_credentials? && @event.ticket_assignation?
  end

  def path
    "events/events/tickets"
  end

  def event_started?
    @event.started?
  end

  def call_to_action
    if event_started?
      t("dashboard.admissions.call_to_action_started")
    else
      t("dashboard.admissions.call_to_action")
    end
  end
end
