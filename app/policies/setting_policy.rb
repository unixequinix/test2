class SettingPolicy < ApplicationPolicy
  def show?
    user.admin_or_promoter?
  end
end
