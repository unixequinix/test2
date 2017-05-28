class EventRegistrationPolicy < ApplicationPolicy
  def resend?
    true
  end

  def destroy?
    admin_and_promoter
  end
end
