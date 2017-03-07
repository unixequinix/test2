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
    user.admin? || (user.promoter? && user.owned_events.include?(record.station.event))
  end

  def admin_promoter_and_support
    admin_and_promoter || (user.support? && user.event.eql?(record.station.event))
  end
end
