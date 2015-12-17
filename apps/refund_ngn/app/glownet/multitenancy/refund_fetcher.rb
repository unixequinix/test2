class Multitenancy::RefundFetcher
  def initialize(event)
    @event = event
  end

  def tickets
    Ticket.where(event: @event).all
  end

  def gtags
    Gtag.where(event: @event).all
  end

  def claims
    Claim.joins(:customer_event_profile).where(customer_event_profiles: { event_id: @event.id })
  end

  def refunds
    Refund.joins(claim: :customer_event_profile)
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
