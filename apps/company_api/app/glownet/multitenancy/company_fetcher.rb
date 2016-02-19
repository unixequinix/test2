class Multitenancy::CompanyFetcher
  def initialize(event, company)
    @event = event
    @company = company
  end

  def company_ticket_types
    CompanyTicketType.where(event: @event)
  end

  def gtags
    Gtag.joins(:company_ticket_type, company_ticket_type: :company)
      .where(event: @event, companies: { name: @company.name })
  end

  def tickets
    Ticket.joins(:company_ticket_type, company_ticket_type: :company)
      .where(event: @event, companies: { name: @company.name })
  end

  def banned_tickets
    tickets.banned
  end

  def banned_gtags
    gtags.banned
  end
end
