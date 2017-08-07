class StatPolicy < ApplicationPolicy
  def cashless?
    user.admin? || user.event_ids.include?(record.scope_for_create["event_id"])
  end

  def stations?
    user.admin? || user.event_ids.include?(record.scope_for_create["event_id"])
  end
end
