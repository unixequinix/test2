class Multitenancy::CompanyFetcher
  def initialize(event, agreement)
    @event = event
    @agreement = agreement
  end

  def company_ticket_types
    @event.company_ticket_types.where(company_event_agreement: @agreement.id)
  end

  def gtags
    @event.gtags
          .joins(company_ticket_type: :company_event_agreement)
          .where(company_ticket_types: { company_event_agreement_id: @agreement.id })
          .joins("LEFT OUTER JOIN purchasers
              ON purchasers.credentiable_id = gtags.id
              AND purchasers.credentiable_type = 'Gtag'
              AND purchasers.deleted_at IS NULL")
          .includes(:purchaser)
  end

  def tickets
    @event.tickets
          .joins(company_ticket_type: :company_event_agreement)
          .where(company_ticket_types: { company_event_agreement_id: @agreement.id })
          .joins("LEFT OUTER JOIN purchasers
              ON purchasers.credentiable_id = tickets.id
              AND purchasers.credentiable_type = 'Ticket'
              AND purchasers.deleted_at IS NULL")
          .includes(:purchaser)
  end

  def banned_tickets
    tickets.where(banned: true)
  end

  def banned_gtags
    gtags.where(banned: true)
  end
end
