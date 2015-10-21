class Multitenancy::CheckingFetcher

  def initialize(event)
    @event = event
  end

  def tickets
    Ticket.where(event: @event).all
  end

  def gtags
    Gtag.where(event: @event).all
  end

  def ticket_types
    TicketType.where(event: @event).all
  end

  def entitlements
    Entitlement.where(event: @event).all
  end

  def admissions
    Admission.where(event: @event).all
  end

  def gtag_registrations
    GtagRegistration.where(event: @event).all
  end

end