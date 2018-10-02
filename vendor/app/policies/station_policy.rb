class StationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      event = Event.find(scope.scope_for_create["event_id"])
      registration = user.registration_for(event)

      case
        when user.admin? || registration&.promoter? then scope.all
        when registration&.vendor_manager? then scope.where(category: "vendor")
        when registration&.role&.in?(%w[pos_money_manager pos_stock_manager monetary_manager]) then scope.where(category: %w[vendor bar])
        when registration&.staff_manager? then scope.where(category: "staff_accreditation")
        else scope.none
      end
    end
  end

  def show?
    case record.category
      when "vendor" then admin_or_promoter_or(:monetary_manager, :vendor_manager, :pos_money_manager, :pos_stock_manager)
      when "bar" then admin_or_promoter_or(:monetary_manager, :pos_money_manager, :pos_stock_manager)
      when "staff_accreditation" then admin_or_promoter_or(:staff_manager)
      else admin_or_promoter
    end
  end

  def clone?
    admin_or_promoter && event_open
  end

  def sort?
    admin_or_promoter && event_open
  end

  def hide?
    admin_or_promoter && event_open
  end

  def unhide?
    admin_or_promoter && event_open
  end

  def add_ticket_types?
    admin_or_promoter && event_open
  end

  def remove_ticket_types?
    admin_or_promoter && event_open
  end
end
