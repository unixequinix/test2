class TicketTypePolicy < ApplicationPolicy
  def tickets?
    admin_or_promoter
  end

  def bulk_upload?
    admin_or_promoter
  end

  private

  def all_allowed
    registration = user.registration_for(record.event)
    if record.operator?
      user.admin? || (registration && (registration.staff_accreditation? || registration.promoter?))
    else
      user.admin? || (registration && (registration.support? || registration.promoter?))
    end
  end
end
