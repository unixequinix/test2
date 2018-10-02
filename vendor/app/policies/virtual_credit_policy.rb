class VirtualCreditPolicy < ApplicationPolicy
  def new?
    admin_or_promoter && record.event.created?
  end

  def create?
    admin_or_promoter && record.event.created?
  end

  def edit?
    admin_or_promoter && record.event.created?
  end

  def update?
    admin_or_promoter && record.event.created?
  end

  def destroy?
    admin_or_promoter && record.event.created?
  end

  def sort?
    admin_or_promoter && record.event.created?
  end
end
