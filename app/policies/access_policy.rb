class AccessPolicy < ApplicationPolicy
  def capacity?
    admin_or_promoter
  end

  def ticket_type?
    admin_or_promoter
  end
end
