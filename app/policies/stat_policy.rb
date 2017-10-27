class StatPolicy < ApplicationPolicy
  def reports?
    user.glowball?
  end

  def cashless?
    user.glowball?
  end

  def stations?
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
end
