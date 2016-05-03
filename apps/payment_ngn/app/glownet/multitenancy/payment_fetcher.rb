class Multitenancy::PaymentFetcher
  def initialize(event)
    @event = event
  end

  def customer_orders
    CustomerOrder.joins(:profile)
      .where(profiles: { event_id: @event.id })
  end

  def orders
    Order.joins(:profile)
      .where(profiles: { event_id: @event.id })
  end

  def payments
    Payment.joins(order: :profile)
      .where(profiles: { event_id: @event.id })
  end

  private

  def admin?
    @user.is_admin?
  end

  def manager?
    @user.is_manager?
  end
end
