class GtagPolicy < ApplicationPolicy
  def solve_inconsistent?
    admin_promoter_and_support && event_open
  end

  def recalculate_balance?
    admin_promoter_and_support && event_open
  end

  def ban?
    admin_promoter_and_support && event_open
  end

  def unban?
    admin_promoter_and_support && event_open
  end

  def import?
    admin_and_promoter && event_open
  end

  def sample_csv?
    admin_and_promoter && event_open
  end
end
