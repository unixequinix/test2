class CreditPolicy < ApplicationPolicy
  def index?
    user.admin? || (user.promoter? && user.owned_events.include?(record.event)) || (user.support? && user.event.eql?(record.event))
  end
end
