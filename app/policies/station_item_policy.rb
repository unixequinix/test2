class StationItemPolicy < ApplicationPolicy
  def index?
    all_allowed
  end

  def show?
    all_allowed
    scope.where(id: record.id).exists?
  end

  def create?
    admin_or_promoter && event_open
  end

  def new?
    admin_or_promoter && event_open
  end

  def update?
    admin_or_promoter && event_open
  end

  def edit?
    admin_or_promoter && event_open
  end

  def destroy?
    admin_or_promoter && record.station.event.created?
  end

  def sort?
    admin_or_promoter && event_open
  end

  def sample_csv?
    admin_or_promoter && event_open
  end

  def import?
    admin_or_promoter && event_open
  end

  private

  def event_open
    !record.station.event.closed?
  end

  def admin_or_promoter
    user.admin? || user.registration_for(record.station.event)&.promoter?
  end

  def all_allowed
    user.admin? || user.registration_for(record.station.event).present?
  end
end
