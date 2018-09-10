class PackPolicy < ApplicationPolicy
  def clone?
    admin_or_promoter
  end

  def edit?
    admin_or_promoter && event_created
  end

  def update?
    admin_or_promoter && event_created
  end
end
