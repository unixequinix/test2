class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def can_login?
    true
  end

  def show?
    user.admin? || user.registration_for(record).present?
  end

  def new?
    user.admin?
  end

  def sample_event?
    user.glowball? || user.admin?
  end

  def create?
    user.admin?
  end

  def edit?
    admin_or_promoter
  end

  def refund_fields?
    admin_or_promoter && event_open
  end

  def versions?
    true
  end

  def launch?
    admin_or_promoter && event_open
  end

  def close?
    admin_or_promoter && event_open
  end

  def update?
    admin_or_promoter && event_open
  end

  def remove_logo?
    admin_or_promoter && event_open
  end

  def remove_background?
    admin_or_promoter && event_open
  end

  def zoho_report?
    admin_or_promoter
  end

  def remove_db?
    admin_or_promoter && event_open
  end

  def event_settings?
    admin_or_promoter
  end

  def missing?
    admin_or_promoter
  end

  def resolvable?
    admin_or_promoter
  end

  def real?
    admin_or_promoter
  end

  def inconsistencies?
    missing? || resolvable? || real?
  end

  def destroy?
    user.admin? && record.created?
  end

  def analytics?
    admin_or_promoter_or(:gates_manager, :monetary_manager, :vendor_manager, :pos_money_manager, :pos_stock_manager)
  end

  def custom_analytics?
    admin_or_promoter_or(:gates_manager, :monetary_manager)
  end

  class Scope < Scope
    def resolve
      case
        when user.glowball? then scope.all
        when user.team_leader? then user.team.events.scope.all
        else user.events.scope
      end
    end
  end

  private

  def event_open
    !record.closed?
  end

  def admin_or_promoter
    registration = user.registration_for(record)
    user.admin? || registration&.promoter?
  end
end
