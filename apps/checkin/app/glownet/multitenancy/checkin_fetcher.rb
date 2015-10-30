class Multitenancy::CheckinFetcher

  def initialize(event)
    @event = event
  end

  def admissions
    Admission.where(event: @event)
  end

  def entitlements
    Entitlement.where(event: @event)
  end

  def gtag_registrations
    GtagRegistration.where(event: @event)
  end

  def gtags
    Gtag.where(event: @event)
  end

  def tickets
    Ticket.where(event: @event)
  end

  def ticket_types
    TicketType.where(event: @event)
  end

  def customer_event_profiles
    CustomerEventProfile.where(event: @event)
  end

end