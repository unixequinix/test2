class AlertPolicy < ApplicationPolicy
  def index?
    user.admin? || user.event_registrations.find_by(event_id: record.scope_for_create["event_id"], role: "promoter").present?
  end

  def read_all?
    admin_or_promoter
  end
end
