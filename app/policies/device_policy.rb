class DevicePolicy < ApplicationPolicy
  def download_db?
    user.admin?
  end
end
