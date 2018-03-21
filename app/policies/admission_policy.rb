class AdmissionPolicy < ApplicationPolicy
  def resend_confirmation?
    all_allowed && event_open
  end

  def gtag_replacement?
    all_allowed && event_open
  end

  def assign_gtag?
    all_allowed && event_open
  end

  def refund?
    all_allowed && event_open
  end

  def assign_ticket?
    all_allowed && event_open
  end

  def refunds?
    all_allowed
  end

  def transactions?
    all_allowed
  end

  def reset_password?
    all_allowed && event_open
  end

  def confirm_customer?
    all_allowed && event_open
  end

  def download_transactions?
    admin_or_promoter
  end

  def new_credential?
    all_allowed && event_open
  end

  def create_credential?
    all_allowed && event_open
  end

  def destroy_credential?
    all_allowed && event_open
  end

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

  def virtual_topup?
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

  def merge?
    admin_or_promoter && event_open
  end
end