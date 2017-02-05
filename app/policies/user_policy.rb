class UserPolicy < ApplicationPolicy
  def index?
    admin_and_promoter
  end

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
