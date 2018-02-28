class OrderPolicy < ApplicationPolicy
  def new?
    admin_or_promoter && event_open
  end

  def create?
    admin_or_promoter && event_open
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
