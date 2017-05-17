class UserPolicy < ApplicationPolicy
  def new?
    admin_and_promoter
  end

  def create?
    admin_and_promoter
  end

  def update?
    admin_and_promoter
  end

  def destroy?
    admin_and_promoter
  end
end
