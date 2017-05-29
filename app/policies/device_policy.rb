class DevicePolicy < ApplicationPolicy
  def show?
    all_allowed
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    false
  end

  def update?
    admin_or_promoter
  end

  def edit?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def download_db?
    user.admin?
  end

  private

  def admin_or_promoter
    user.admin? || user.registration_for(user.event_ids & record.event_ids)&.promoter?
  end

  def all_allowed
    user.admin? || user.registration_for(user.event_ids & record.event_ids).present?
  end
end
