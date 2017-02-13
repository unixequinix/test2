class TicketTypePolicy < ApplicationPolicy
  def visibility?
    admin_and_promoter && event_open
  end
end
