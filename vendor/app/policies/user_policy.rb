class UserPolicy < ApplicationPolicy
  def index?
    user.glowball?
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
    user.glowball? || record.eql?(user)
  end

  def edit?
    user.glowball? || record.eql?(user)
  end

  def destroy?
    user.glowball?
  end

  def accept_invitation?
    true
  end

  def refuse_invitation?
    true
  end
end
