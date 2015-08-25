class CreditsPresenter < BasePresenter
  def can_render?
    @event.ticketing?
  end

  def path
    'customers/events/dashboards/credits'
  end

  def customer_credit_sum
    customer_event_profile.credit_logs.sum(:amount).floor
  end

  def event_started?
    @event.started?
  end

  def call_to_action
    if event_started?
      I18n.t('dashboard.credits.call_to_action_started')
    else
      @adminssion ? I18n.t('dashboard.credits.call_to_action') : I18n.t('dashboard.credits.call_to_action_no_admission_html').html_safe
    end
  end

  private

  def customer_event_profile
    @customer_event_profile ||= @admission ? @admission.customer_event_profile : CustomerEventProfile.new
  end
end
