class DeviceRegistrationPolicy < ApplicationPolicy
  def download_db?
    user.admin?
  end

  def resolve_time?
    user.admin?
  end
end
