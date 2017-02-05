class EventPolicy < ApplicationPolicy
  def show?
    admin_and_promoter || (user.support? && user.event.eql?(record))
  end

  def stats?
    admin_and_promoter
  end

  def new?
    user.admin?
  end

  def sample_event?
    user.admin?
  end

  def create?
    user.admin?
  end

  def edit?
    admin_and_promoter
  end

  def edit_credit?
    admin_and_promoter
  end

  def edit_gtag_settings?
    admin_and_promoter
  end

  def edit_device_settings?
    admin_and_promoter
  end

  def gtag_settings?
    admin_and_promoter
  end

  def device_settings?
    admin_and_promoter
  end

  def update?
    admin_and_promoter
  end

  def event_charts?
    admin_and_promoter
  end

  def remove_logo?
    admin_and_promoter
  end

  def remove_background?
    admin_and_promoter
  end

  def remove_db?
    admin_and_promoter
  end

  def event_settings?
    admin_and_promoter
  end

  def load_defaults?
    admin_and_promoter
  end

  def eventbrite_index?
    admin_and_promoter
  end

  def eventbrite_connect?
    admin_and_promoter
  end

  def eventbrite_disconnect?
    admin_and_promoter
  end

  def eventbrite_import_tickets?
    admin_and_promoter
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
    user.admin?
  end

  class Scope < Scope
    def resolve
      case
        when user.admin? then scope.all
        when user.promoter? then scope.where(owner: user)
        when user.support? then scope.where(id: user.event&.id)
      end
    end
  end

  private

  def admin_and_promoter
    user.admin? || (user.promoter? && user.owned_events.include?(record))
  end
end
