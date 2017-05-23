class EventPolicy < ApplicationPolicy
  def show?
    user.admin? || user.registration_for(record).present?
  end

  def stats?
    admin_and_promoter
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
    admin_and_promoter && event_open
  end

  def edit_event_style?
    admin_and_promoter && event_open
  end

  def device_settings?
    admin_and_promoter
  end

  def launch?
    admin_and_promoter && event_open
  end

  def close?
    admin_and_promoter && event_open
  end

  def update?
    admin_and_promoter && event_open
  end

  def event_charts?
    admin_and_promoter
  end

  def remove_logo?
    admin_and_promoter && event_open
  end

  def remove_background?
    admin_and_promoter && event_open
  end

  def remove_db?
    admin_and_promoter && event_open
  end

  def event_settings?
    admin_and_promoter
  end

  def eventbrite_index?
    admin_and_promoter
  end

  def eventbrite_connect?
    admin_and_promoter && event_open
  end

  def eventbrite_disconnect?
    admin_and_promoter
  end

  def eventbrite_import_tickets?
    admin_and_promoter && event_open
  end

  def missing?
    admin_and_promoter
  end

  def resolvable?
    admin_and_promoter
  end

  def real?
    admin_and_promoter
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

  def admin_and_promoter
    user.admin? || (user.registration_for(record)&.promoter? && user.registration_for(record)&.accepted?)
  end
end
