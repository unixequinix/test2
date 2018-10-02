class PokePolicy < ApplicationPolicy
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

  def search?
    admin_or_promoter
  end

  def download?
    admin_or_promoter
  end
end
