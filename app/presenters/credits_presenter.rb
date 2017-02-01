class CreditsPresenter < BasePresenter
  def can_render?
    @customer.active_credentials?
  end

  def path
    @event.topups? ? "events/events/credits" : "events/events/credits_after_event"
  end

  def customer_total_credits
    number_with_precision(@customer.credits, precision: 2)
  end

  def refundable_credits
    @customer.refundable_credits
  end

  def event_started?
    @event.started?
  end

  def refundable_money
    number_with_precision(@customer.refundable_money || 0, precision: 2)
  end

  def token_symbol
    @event.token_symbol
  end

  def currency
    @event.currency
  end

  def valid_balance?
    @customer.active_gtag.nil? || @customer.active_gtag&.valid_balance?
  end

  def call_to_action
    if event_started?
      t("dashboard.credits.call_to_action_started")
    elsif @tickets.any?
      t("dashboard.credits.call_to_action")
    else
      t("dashboard.credits.call_to_action_no_admission_html")
    end
  end
end
