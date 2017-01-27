class StationPolicy < ApplicationPolicy
  def clone?
    admin_and_promoter
  end

  def sort?
    admin_and_promoter
  end

  def visibility?
    admin_and_promoter
  end
end
