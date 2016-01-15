class CreditsPresenter < BasePresenter
  def can_render?
    @event.top_ups?
  end

  def path
    'events/events/credits'
  end

  def customer_total_credits
    @customer_event_profile.total_credits
  end

  def event_started?
    @event.started?
  end

  def call_to_action
    if event_started?
      I18n.t('dashboard.credits.call_to_action_started')
    else
      if @ticket_assignments.any?
        I18n.t('dashboard.credits.call_to_action')
      else
        I18n.t('dashboard.credits.call_to_action_no_admission_html').html_safe
      end
    end
  end
end
