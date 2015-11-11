class Multitenancy::PaymentFetcher
  def initialize(event)
    @event = event
  end

  def orders
    Order.joins(:customer_event_profile)
      .where(customer_event_profiles: { event_id: @event.id })
  end

  def payments
    Payment.joins(order: :customer_event_profile)
      .where(customer_event_profiles: { event_id: @event.id })
  end

  private
  def admin?
    @user.is_admin?
  end

  def manager?
    @user.is_manager?
  end
end