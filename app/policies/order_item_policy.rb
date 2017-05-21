class OrderItemPolicy < ApplicationPolicy
  def update?
    admin?
  end
end
