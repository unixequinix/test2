class Operations::Credential::Base < Operations::Base
  def assign_gtag_credential(gtag, profile_id)
    return if gtag.assigned_gtag_credential
    gtag.create_assigned_gtag_credential!(profile_id: profile_id)
  end

  def unassign_gtag_credential(gtag, profile_id)
    return unless gtag.assigned_gtag_credential
    gtag.assigned_gtag_credential.unassign!
  end

  def assign_ticket(transaction, atts)
    code = atts[:ticket_code]
    event = transaction.event

    # If ticket is found by code, it is already there, assign and return it.
    ticket = event.tickets.find_by_code(code)
    transaction.update!(ticket: ticket) if ticket
    return ticket if ticket

    # Ticket is not found. perhaps is new sonar ticket?
    decoder = TicketDecoder::SonarDecoder
    id = decoder.valid_code?(code) && decoder.perform(code)

    # it is not sonar, it is not in DB. The ticket is not valid.
    raise "Ticket with code #{code} not found and not sonar." unless id

    # ticket is sonar. so insert it.
    ctt = event.company_ticket_types.find_by_company_code(id)
    ticket = event.tickets.create!(code: code, company_ticket_type: ctt)
    transaction.update!(ticket: ticket)
    ticket
  end

  def assign_ticket_credential(ticket, profile_id)
    return if ticket.assigned_ticket_credential
    ticket.create_assigned_ticket_credential!(profile_id: profile_id)
  end

  def mark_redeemed(obj)
    obj.update!(credential_redeemed: true)
  end

  def self.inherited(klass)
    superclass.inherited(klass)
  end
end
