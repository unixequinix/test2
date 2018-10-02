class DevicePolicy < ApplicationPolicy
  def show?
    check_team || user.admin?
  end

  def create?
    check_team || user.admin?
  end

  def new?
    check_team || user.admin?
  end

  def update?
    check_team || user.admin?
  end

  def edit?
    check_team || user.admin?
  end

  def destroy?
    user.admin?
  end

  def remove_devices?
    check_team || user.admin?
  end

  def check_team
    user.team == record.team
  end
end
