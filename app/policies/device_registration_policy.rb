class DeviceRegistrationPolicy < ApplicationPolicy
  def download_db?
    user.admin?
  end

  def resolve_time?
    user.admin?
  end

  def new
    user&.team.present? || user.admin?
  end

  def create?
    user&.team.present? && user&.team&.devices&.include?(record.device) || admin_or_device_register
  end

  def destroy?
    user.admin?
  end

  def disable?
    user&.team&.devices&.include?(record.device) || user.admin?
  end

  def transactions?
    admin_or_promoter
  end
end
