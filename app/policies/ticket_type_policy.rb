class TicketTypePolicy < ApplicationPolicy
  def tickets?
    admin_or_promoter
  end

  def unban?
    admin_or_promoter
  end
end
