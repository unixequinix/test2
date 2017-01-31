class StationItemPolicy < ApplicationPolicy
  def index?
    admin_promoter_and_support
  end

  def show?
    admin_promoter_and_support
    scope.where(id: record.id).exists?
  end

  def create?
    admin_and_promoter
  end

  def new?
    admin_and_promoter
  end

  def update?
    admin_and_promoter
  end

  def edit?
    admin_and_promoter
  end

  def destroy?
    admin_and_promoter
  end

  def visibility?
    admin_and_promoter
  end

  def sort?
    admin_and_promoter
  end

  private

  def admin_and_promoter
    user.admin? || (user.promoter? && user.owned_events.include?(record.station.event))
  end

  def admin_promoter_and_support
    admin_and_promoter || (user.support? && user.event.eql?(record.station.event))
  end
end
