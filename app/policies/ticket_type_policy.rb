class TicketTypePolicy < ApplicationPolicy
  def tickets?
    admin_or_promoter
  end

  def bulk_upload?
    admin_or_promoter
  end

  def unban?
    admin_or_promoter
  end

  private

  def all_allowed
    return true if user.admin?

    registration = user.registration_for(record.event)
    return false unless registration
    return true if registration.promoter?
    record.operator? ? registration.staff_manager? : registration.support?
  end
end
