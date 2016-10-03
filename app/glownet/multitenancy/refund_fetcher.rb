class Multitenancy::RefundFetcher
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
    Claim.joins(:profile).where(profiles: { event_id: @event.id })
  end

  def refunds
    Refund.joins(claim: :profile)
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
