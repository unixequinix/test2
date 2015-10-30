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

  private

    def admin?
      @user.is_admin?
    end

    def manager?
      @user.is_manager?
    end

end