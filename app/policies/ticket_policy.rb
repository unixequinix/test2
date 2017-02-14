class TicketPolicy < ApplicationPolicy
  def import?
    admin_and_promoter && event_open
  end

  def sample_csv?
    admin_and_promoter
  end

  def ban?
    admin_and_promoter && event_open
  end

  def unban?
    admin_and_promoter && event_open
  end
end
