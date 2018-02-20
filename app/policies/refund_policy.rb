class RefundPolicy < ApplicationPolicy
  def stats?
    admin_or_promoter
  end

  def complete?
    admin_or_promoter
  end

  def cancel?
    admin_or_promoter
  end

  def destroy?
    user.admin?
  end
end
