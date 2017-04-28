class OrderPolicy < ApplicationPolicy
  def stats?
    admin_and_promoter
  end
end
