class AccessPolicy < ApplicationPolicy
  def show?
    admin_or_promoter_or(:support, :gates_manager)
  end

  def edit?
    admin_or_promoter && event_created
  end

  def update?
    admin_or_promoter && event_created
  end

  def capacity?
    admin_or_promoter
  end

  def ticket_type?
    admin_or_promoter
  end
end
