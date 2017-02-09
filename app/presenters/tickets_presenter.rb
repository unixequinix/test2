class TicketsPresenter < BasePresenter
  def can_render?
    true
  end

  def path
    "events/events/tickets"
  end

  def event_started?
    @event.started?
  end

  def call_to_action
    if event_started?
      I18n.t("dashboard.admissions.call_to_action_started")
    else
      I18n.t("dashboard.admissions.call_to_action")
    end
  end
end
