class EventRegistrationPolicy < ApplicationPolicy
  def accept?
    true
  end

  def destroy?
    admin_and_promoter
  end
end
