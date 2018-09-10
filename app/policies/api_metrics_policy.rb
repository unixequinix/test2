class ApiMetricsPolicy < ApplicationPolicy
  def all?
    user.glowball?
  end
end
