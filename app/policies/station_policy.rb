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

  def hide?
    admin_or_promoter && event_open
  end

  def unhide?
    admin_or_promoter && event_open
  end

  def reports?
    admin_or_promoter
  end
end
