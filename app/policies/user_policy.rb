class UserPolicy < ApplicationPolicy
  def index?
    admin_and_promoter
  end

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
    admin_and_promoter && record.event.created? && recrod.event.active?
  end
end
