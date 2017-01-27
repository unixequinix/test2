class DevicePolicy < ApplicationPolicy
  def index?
    admin.admin? || admin.promoter?
  end
end
