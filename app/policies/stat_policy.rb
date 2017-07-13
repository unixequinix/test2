class StatPolicy < ApplicationPolicy
  def cashless?
    admin_or_promoter
  end

  def stations?
    admin_or_promoter
  end

  def products?
    admin_or_promoter
  end
end
