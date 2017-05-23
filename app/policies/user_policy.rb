class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || record.eql?(user)
  end

  def create?
    true
  end

  def new?
    true
  end

  def update?
    user.admin? || record.eql?(user)
  end

  def edit?
    user.admin? || record.eql?(user)
  end

  def destroy?
    user.admin?
  end
end
