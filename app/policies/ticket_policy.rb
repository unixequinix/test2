class TicketPolicy < ApplicationPolicy
  def topup?
    all_allowed && event_open
  end

  def import?
    admin_or_promoter && event_open
  end

  def sample_csv?
    admin_or_promoter
  end

  def ban?
    admin_or_promoter && event_open
  end

  def unban?
    admin_or_promoter && event_open
  end
end
