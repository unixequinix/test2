class PokePolicy < ApplicationPolicy
  def analytics?
    user.glowball?
  end

  def analytics_billing?
    user.glowball?
  end

  def issues?
    user.glowball?
  end

  def edit?
    user.glowball?
  end

  def update?
    user.glowball?
  end

  def update_multiple?
    user.glowball?
  end

  def status_9?
    admin_or_promoter && event_open
  end

  def status_0?
    admin_or_promoter && event_open
  end
end
