class UserPolicy < ApplicationPolicy
  def new?
    admin_and_promoter && event_open
  end

  def create?
    admin_and_promoter && event_open
  end

  def update?
    admin_and_promoter && event_open
  end

  def destroy?
    admin_and_promoter
  end
end
