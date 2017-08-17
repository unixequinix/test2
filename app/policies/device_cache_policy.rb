class DeviceCachePolicy < ApplicationPolicy
  def destroy?
    user.admin?
  end
end
