class EventPolicy < ApplicationPolicy
  def show?
    user.admin? || user.registration_for(record).present?
  end

  def stats?
    admin_or_promoter
  end

  def new?
    true
  end

  def sample_event?
    user.admin?
  end

  def create?
    true
  end

  def edit?
    admin_or_promoter && event_open
  end

  def edit_event_style?
    admin_or_promoter && event_open
  end

  def device_settings?
    admin_or_promoter
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

  def event_charts?
    admin_or_promoter
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

  class Scope < Scope
    def resolve
      case
        when user.admin? then scope.all.order(:name)
        else user.events.order(:name)
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
