class OrderItemPolicy < ApplicationPolicy
  def update?
    user.admin?
  end
end
