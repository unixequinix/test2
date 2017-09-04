class StatPolicy < ApplicationPolicy
  def cashless?
    user.admin?
  end

  def stations?
    user.admin?
  end
end
