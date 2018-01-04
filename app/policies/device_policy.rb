class DevicePolicy < ApplicationPolicy
  def show?
    user.admin?
  end

  def create?
    false
  end

  def new?
    false
  end

  def update?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def remove_devices?
    user.team == record.team || user.admin?
  end
end
