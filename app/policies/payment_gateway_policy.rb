class PaymentGatewayPolicy < ApplicationPolicy
  def index?
    admin_or_promoter
  end

  def topup?
    admin_or_promoter && event_open
  end

  def refund?
    admin_or_promoter && event_open
  end
end
