class AdmissionPolicy < ApplicationPolicy
  def index?
    user.admin? || user.event_ids.include?(record.scope_for_create["event_id"])
  end

  def show?
    all_allowed && scope.where(id: record.id).exists?
  end

  def create?
    all_allowed && event_open
  end

  def new?
    all_allowed && event_open
  end

  def update?
    all_allowed && event_open
  end

  def edit?
    all_allowed && event_open
  end

  def destroy?
    all_allowed && record.event.created?
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
    all_allowed
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
    all_allowed && event_open
  end

  def sample_csv?
    all_allowed && event_open
  end

  def merge?
    all_allowed && event_open
  end

  def make_active?
    all_allowed && event_open
  end

  def create_sonar_operator?
    all_allowed && event_open
  end

  def can_login?
    true
  end

  def store_redirection?
    all_allowed
  end

  private

  def all_allowed
    return true if user.admin?

    registration = user.registration_for(record.event)
    return false unless registration
    return true if registration.promoter?
    record.operator? ? registration.staff_manager? : registration.support?
  end
end
