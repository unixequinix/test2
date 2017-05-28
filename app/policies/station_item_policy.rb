class StationItemPolicy < ApplicationPolicy
  def index?
    admin_promoter_and_support
  end

  def show?
    admin_promoter_and_support
    scope.where(id: record.id).exists?
  end

  def create?
    admin_and_promoter && event_open
  end

  def new?
    admin_and_promoter && event_open
  end

  def update?
    admin_and_promoter && event_open
  end

  def edit?
    admin_and_promoter && event_open
  end

  def destroy?
    admin_and_promoter && record.station.event.created?
  end

  def sort?
    admin_and_promoter && event_open
  end

  private

  def event_open
    !record.station.event.closed?
  end

  def admin_and_promoter
    user.admin? || (user.registration_for(record.station.event)&.promoter? && user.registration_for(record.station.event).present?)
  end

  def admin_promoter_and_support
    user.admin? || (user.registration_for(record.station.event)&.support? && user.registration_for(record.station.event).present?)
  end
end
