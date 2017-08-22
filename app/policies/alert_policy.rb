class AlertPolicy < ApplicationPolicy
  def index?
    user.admin? || user.event_registrations.find_by(event_id: record.scope_for_create["event_id"], role: "promoter").present?
  end

  def read_all?
    user.admin? || user.registration_for(record.scope_for_create["event_id"])&.promoter?
  end
end
