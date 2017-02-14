class StationPolicy < ApplicationPolicy
  def clone?
    admin_and_promoter && event_open
  end

  def sort?
    admin_and_promoter && event_open
  end

  def visibility?
    admin_and_promoter && event_open
  end
end
