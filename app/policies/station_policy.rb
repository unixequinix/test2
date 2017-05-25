class StationPolicy < ApplicationPolicy
  def add_product?
    admin_and_promoter
  end

  def remove_product?
    admin_and_promoter
  end

  def clone?
    admin_and_promoter && event_open
  end

  def sort?
    admin_and_promoter && event_open
  end
end
