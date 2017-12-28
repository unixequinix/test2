class StatPolicy < ApplicationPolicy
  def reports?
    user.glowball?
  end

  def money_recon?
    user.glowball?
  end

  def products_sale?
    user.glowball?
  end

  def cashless?
    user.glowball?
  end

  def activations?
    user.glowball?
  end

  def devices?
    user.glowball?
  end

  def gates?
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
