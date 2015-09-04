class AdmissionsPresenter < BasePresenter
  def can_render?
    @event.ticketing? && !event_started?
  end

  def path
    @admission ? 'events/events/admission_form' :
                  'events/events/admission_activation'
  end

  def ticket_number
    @admission.ticket.number
  end

  def event_started?
    @event.started?
  end

  def call_to_action
    if event_started?
      I18n.t('dashboard.admissions.call_to_action_started')
    else
      I18n.t('dashboard.admissions.call_to_action')
    end
  end
end
