class StationPolicy < ApplicationPolicy
  def clone?
    admin_or_promoter && event_open
  end

  def sort?
    admin_or_promoter && event_open
  end

  def hide?
    admin_or_promoter && event_open
  end

  def unhide?
    admin_or_promoter && event_open
  end

  def add_ticket_types?
    admin_or_promoter && event_open
  end

  def remove_ticket_types?
    admin_or_promoter && event_open
  end
end
