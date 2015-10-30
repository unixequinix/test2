class Multitenancy::AdministrationFetcher

  def initialize(event)
    @event = event
  end

  def tickets
    Ticket.where(event: @event)
  end

  def gtags
    Gtag.where(event: @event)
  end

  def claims
    Claim.joins(:customer_event_profile).where(customer_event_profiles: { event_id: @event.id })
  end

  def credits
    Credit.joins(:online_product).where(online_products: { event_id: @event.id })
  end

  def customer_event_profiles
    CustomerEventProfile.where(event_id: @event.id)
  end

  def event_parameters
    EventParameter.where(event_id: @event.id)
  end

  def orders
    Order.joins(:customer_event_profile)
      .where(customer_event_profiles: { event_id: @event.id })
  end

  def payments
    Payment.joins(order: :customer_event_profile)
      .where(customer_event_profiles: { event_id: @event.id })
  end

  def refunds
    Refund.joins(claim: :customer_event_profile)
      .where(customer_event_profiles: { event_id: current_event.id })
  end

  private

    def admin?
      @user.is_admin?
    end

    def manager?
      @user.is_manager?
    end

end