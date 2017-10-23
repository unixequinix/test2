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
end
