class TicketTypePolicy < ApplicationPolicy
  def visibility?
    admin_and_promoter
  end
end
