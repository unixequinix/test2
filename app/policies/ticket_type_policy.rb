class TicketTypePolicy < ApplicationPolicy
  def tickets?
    admin_or_promoter
  end

  def bulk_upload?
    admin_or_promoter
  end
end
