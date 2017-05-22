class RefundPolicy < ApplicationPolicy
  def complete?
    admin_and_promoter
  end
end
