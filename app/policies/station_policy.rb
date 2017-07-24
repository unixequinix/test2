class StationPolicy < ApplicationPolicy
  def add_product?
    admin_or_promoter
  end

  def remove_product?
    admin_or_promoter
  end

  def update_product?
    admin_or_promoter
  end

  def clone?
    admin_or_promoter && event_open
  end

  def sort?
    admin_or_promoter && event_open
  end
end
