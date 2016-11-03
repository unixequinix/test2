class CreditsPresenter < BasePresenter
  def can_render?
    @profile.active_credentials?
  end

  def path
    @event.top_ups? ? "events/events/credits" : "events/events/credits_after_event"
  end

  def customer_total_credits
    number_with_precision(@profile.credits, precision: 2)
  end

  def refundable_credits
    @profile.refundable_credits
  end

  def event_started?
    @event.started?
  end

  def refundable_money
    number_with_precision(@profile.refundable_money, precision: 2)
  end

  def token_symbol
    @event.token_symbol
  end

  def currency
    @event.currency
  end

  def valid_balance?
    @profile.valid_balance?
  end

  def call_to_action
    if event_started?
      I18n.t("dashboard.credits.call_to_action_started")
    elsif @tickets.any?
      I18n.t("dashboard.credits.call_to_action")
    else
      I18n.t("dashboard.credits.call_to_action_no_admission_html").html_safe
    end
  end
end