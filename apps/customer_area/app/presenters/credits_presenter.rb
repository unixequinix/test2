class CreditsPresenter < BasePresenter
  def can_render?
    @event.top_ups?
  end

  def path
    @event.finished? ? "events/events/credits_after_event" : "events/events/credits"
  end

  def customer_total_credits
    @customer_event_profile.total_credits
  end

  def event_started?
    @event.started?
  end

  def refundable_credits
    @customer_event_profile.refundable_credits_amount
  end

  def refundable_money
    @customer_event_profile.refundable_money_amount
  end

  def valid_balance?
    BalanceCalculator.new(@customer_event_profile).valid_balance?
  end

  def call_to_action
    if event_started?
      I18n.t("dashboard.credits.call_to_action_started")
    else
      if @ticket_assignments.any?
        I18n.t("dashboard.credits.call_to_action")
      else
        I18n.t("dashboard.credits.call_to_action_no_admission_html").html_safe
      end
    end
  end
end
