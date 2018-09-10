class OrderPolicy < ApplicationPolicy
  def new?
    all_allowed && event_open
  end

  def create?
    all_allowed && event_open
  end

  def analytics?
    all_allowed
  end

  def complete?
    all_allowed
  end

  def destroy?
    user.admin? && event_created
  end
end
