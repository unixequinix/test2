class TicketingIntegrationPolicy < ApplicationPolicy
  def show?
    admin_or_promoter
  end

  def activate?
    admin_or_promoter
  end

  def deactivate?
    admin_or_promoter
  end

  def connect?
    admin_or_promoter
  end

  def import_tickets?
    admin_or_promoter
  end

  def index?
    admin_or_promoter
  end

  def new?
    admin_or_promoter
  end

  def create?
    admin_or_promoter
  end

  def destroy?
    admin_or_promoter && record.ticket_types.blank?
  end
end
