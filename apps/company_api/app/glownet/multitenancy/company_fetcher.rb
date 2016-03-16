class Multitenancy::CompanyFetcher
  def initialize(event, agreement)
    @event = event
    @agreement = agreement
  end

  def company_ticket_types
    CompanyTicketType.where(event: @event, company_event_agreement: @agreement.id)
  end

  def gtags
    @event.gtags
      .joins(company_ticket_type: :company_event_agreement)
      .where(company_ticket_types: { company_event_agreement_id: @agreement.id })
  end

  def tickets
    @event.tickets
      .with_deleted
      .joins(company_ticket_type: :company_event_agreement)
      .where(company_ticket_types: { company_event_agreement_id: @agreement.id })
  end

  def banned_tickets
    tickets.banned
  end

  def banned_gtags
    gtags.banned
  end
end
