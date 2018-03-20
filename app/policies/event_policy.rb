class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.glowball? || user.registration_for(record).present?
  end

  def new?
    true
  end

  def sample_event?
    user.glowball? || user.admin?
  end

  def create?
    true
  end

  def edit?
    admin_or_promoter && event_open
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

  def remove_db?
    admin_or_promoter && event_open
  end

  def event_settings?
    admin_or_promoter
  end

  def eventbrite_index?
    admin_or_promoter
  end

  def eventbrite_connect?
    admin_or_promoter && event_open
  end

  def eventbrite_disconnect?
    admin_or_promoter
  end

  def eventbrite_import_tickets?
    admin_or_promoter && event_open
  end

  def universe_index?
    admin_or_promoter
  end

  def universe_connect?
    admin_or_promoter && event_open
  end

  def universe_disconnect?
    admin_or_promoter
  end

  def universe_import_tickets?
    admin_or_promoter && event_open
  end

  def palco4_index?
    admin_or_promoter
  end

  def palco4_show?
    admin_or_promoter
  end

  def missing?
    admin_or_promoter
  end

  def resolvable?
    admin_or_promoter
  end

  def resolve_time?
    user.admin?
  end

  def do_resolve_time?
    user.admin?
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
    admin_or_promoter
  end

  def custom_analytics?
    admin_or_promoter
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
