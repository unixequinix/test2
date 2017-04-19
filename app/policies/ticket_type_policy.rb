class TicketTypePolicy < ApplicationPolicy
  def tickets?
    admin_and_promoter
  end

  def unban?
    admin_and_promoter
  end
end
