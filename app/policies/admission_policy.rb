class AdmissionPolicy < ApplicationPolicy
  def show?
    all_allowed && scope.where(id: record.id).exists?
  end

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

  def make_active?
    admin_or_promoter && event_open
  end

  def create_sonar_operator?
    all_allowed && event_open
  end

  private

  def all_allowed
    registration = user.registration_for(record.event)
    if record.operator?
      user.admin? || (registration && (registration.staff_accreditation? || registration.promoter?))
    else
      user.admin? || (registration && (registration.support? || registration.promoter?))
    end
  end
end
