class DevicePolicy < ApplicationPolicy
  def index?
    user.admin? || user.promoter?
  end
end
