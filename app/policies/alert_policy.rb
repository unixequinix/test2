class AlertPolicy < ApplicationPolicy
  def index?
    user.admin? || user.id.eql(record.scope_for_create["user_id"])
  end

  def update?
    user.admin? || user.alerts.include?(record)
  end

  def destroy?
    user.admin? || user.alerts.include?(record)
  end
end
