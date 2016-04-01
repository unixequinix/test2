class PurchasesPresenter < BasePresenter
  def can_render?
    !@event.closed? && @purchases.present? && @customer_event_profile.active_credentials?
  end

  def path
    "purchases"
  end

  def call_to_action
    I18n.t("dashboard.refunds.call_to_action", date: formatted_date)
  end
end
