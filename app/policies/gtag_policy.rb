class GtagPolicy < ApplicationPolicy
  def destroy_multiple?
    admin_and_promoter
  end

  def solve_inconsistent?
    admin_promoter_and_support
  end

  def recalculate_balance?
    admin_promoter_and_support
  end

  def ban?
    admin_promoter_and_support
  end

  def unban?
    admin_promoter_and_support
  end

  def import?
    admin_and_promoter
  end

  def sample_csv?
    admin_and_promoter
  end
end
