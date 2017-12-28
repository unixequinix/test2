class GtagPolicy < ApplicationPolicy
  def missing_transactions?
    all_allowed
  end

  def inconsistencies?
    all_allowed
  end

  def replace?
    all_allowed && event_open
  end

  def topup?
    all_allowed && event_open
  end

  def solve_inconsistent?
    all_allowed && event_open
  end

  def recalculate_balance?
    all_allowed && event_open
  end

  def ban?
    all_allowed && event_open
  end

  def unban?
    all_allowed && event_open
  end

  def import?
    admin_or_promoter && event_open
  end

  def sample_csv?
    admin_or_promoter && event_open
  end
end
