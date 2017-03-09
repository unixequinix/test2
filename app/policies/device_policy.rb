class DevicePolicy < ApplicationPolicy
  def index?
    user.admin? || user.promoter?
  end

  def download_db?
    user.admin?
  end
end
