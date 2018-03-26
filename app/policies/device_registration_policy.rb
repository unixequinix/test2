class DeviceRegistrationPolicy < ApplicationPolicy
  def download_db?
    user.admin?
  end

  def new?
    event_open? && user&.team.present? || user.glowball?
  end

  def create?
    event_open && (user&.team.present? && user&.team&.devices&.include?(record.device) || admin_or_device_register)
  end

  def destroy?
    user.admin?
  end

  def disable?
    user&.team.present? && user&.team&.devices&.include?(record.device) || admin_or_device_register
  end

  def transactions?
    admin_or_promoter
  end
end
