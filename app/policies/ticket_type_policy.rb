class TicketTypePolicy < ApplicationPolicy
  def unban?
    admin_and_promoter
  end
end
