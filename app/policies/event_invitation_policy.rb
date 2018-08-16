class EventInvitationPolicy < ApplicationPolicy
  def resend?
    true
  end

  def create?
    admin_or_promoter
  end

  def new?
    admin_or_promoter
  end

  def update?
    admin_or_promoter
  end

  def edit?
    admin_or_promoter
  end

  def destroy?
    admin_or_promoter
  end

  def accept?
    true
  end
end
