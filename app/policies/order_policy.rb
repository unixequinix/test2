class OrderPolicy < ApplicationPolicy
  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def stats?
    admin_and_promoter
  end

  def complete?
    admin_and_promoter
  end

  def destroy?
    user.admin?
  end
end
