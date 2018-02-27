class OrderPolicy < ApplicationPolicy
  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def analytics?
    admin_or_promoter
  end

  def complete?
    admin_or_promoter
  end

  def destroy?
    user.admin?
  end
end
