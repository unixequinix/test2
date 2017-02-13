class PaymentGatewayPolicy < ApplicationPolicy
  def index?
    admin_and_promoter
  end

  def topup?
    admin_and_promoter && event_open
  end

  def refund?
    admin_and_promoter && event_open
  end
end
