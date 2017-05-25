class RefundPolicy < ApplicationPolicy
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
