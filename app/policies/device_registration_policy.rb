class DeviceRegistrationPolicy < ApplicationPolicy
  def download_db?
    user.admin?
  end

  def resolve_time?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
