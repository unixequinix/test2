class AnalyticsPolicy < ApplicationPolicy
  def dashboard?
    admin_or_promoter_or(:gates_manager)
  end

  def cash_flow?
    true
  end

  def credits_flow?
    true
  end

  def tokens_flow?
    true
  end

  def partner_reports?
    true
  end

  def checkin?
    admin_or_promoter_or(:gates_manager)
  end

  def access_control?
    admin_or_promoter_or(:gates_manager)
  end

  def engagement?
    admin_or_promoter
  end

  def custom_seasplash?
    true
  end

  def custom_voucher?
    true
  end

  def custom_lambeth?
    true
  end

  def sub_report?
    true
  end

  def credit_topups?
    true
  end

  def credit_sales?
    true
  end

  def credit_orders?
    true
  end

  def credit_credentials?
    true
  end

  def credit_box_office?
    true
  end

  def credit_onsite_refunds?
    true
  end

  def credit_online_refunds?
    true
  end

  def credit_outcome_fees?
    true
  end

  def credit_income_fees?
    true
  end

  def credit_outcome_orders?
    true
  end

  def money_topups?
    true
  end

  def money_orders?
    true
  end

  def money_box_office?
    true
  end

  def money_fees?
    true
  end

  def money_online_refunds?
    true
  end

  def money_onsite_refunds?
    true
  end

  def money_income_fees?
    true
  end

  private

  def event_open
    !record.closed?
  end

  def admin_or_promoter_or(role)
    registration = user.registration_for(record)
    user.admin? || registration&.promoter? || registration.method("#{role}?".to_sym).call
  end
end
