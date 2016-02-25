class Multitenancy::CompanyFetcher
  def initialize(event, agreement)
    @event = event
    @agreement = agreement
  end

  def company_ticket_types
    CompanyTicketType.where(event: @event, company_event_agreement: @agreement.id)
  end

  def gtags
    Gtag.joins(company_ticket_type: :company_event_agreement)
      .where(event: @event, company_event_agreements: { id: @agreement.id })
  end

  def tickets
    Ticket.joins(company_ticket_type: :company_event_agreement)
      .where(event: @event, company_event_agreements: { id: @agreement.id })
  end

  def banned_tickets
    tickets.banned
  end

  def banned_gtags
    gtags.banned
  end
end
