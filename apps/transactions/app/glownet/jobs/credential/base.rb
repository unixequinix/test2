class Jobs::Credential::Base < Jobs::Base
  def assign_gtag(transaction, atts)
    gtags = transaction.event.gtags
    ctt = transaction.ticket.company_ticket_type
    create_atts = { tag_uid: atts[:customer_tag_uid], company_ticket_type: ctt }
    gtags.find_by_tag_uid(atts[:customer_tag_uid]) || gtags.create!(create_atts)
  end

  def assign_gtag_credential(gtag, profile)
    return if gtag.assigned_gtag_credential
    gtag.create_assigned_gtag_credential!(customer_event_profile: profile)
  end

  def assign_ticket(transaction, atts)
    code = atts[:ticket_code]
    event = transaction.event

    # If ticket is found by code, it is already there, assign and return it.
    ticket = event.tickets.find_by_code(code)
    transaction.update_attributes(ticket: ticket) if ticket
    return ticket if ticket

    # Ticket is not found. perhaps is new sonar ticket?
    id = TicketDecoder::SonarDecoder.valid_code?(code) && TicketDecoder::SonarDecoder.perform(code)

    # it is not sonar, it is not in DB. The ticket is not valid.
    fail "Ticket with code #{code} not found and not sonar." unless id

    ctt = event.company_ticket_types.find_by_company_code(id)
    transaction.create_ticket!(event: event, code: code, company_ticket_type: ctt)
  end

  def assign_ticket_credential(ticket, profile)
    return if ticket.assigned_ticket_credential
    ticket.create_assigned_ticket_credential!(customer_event_profile: profile)
  end

  def mark_redeemed(obj)
    obj.update!(credential_redeemed: true)
  end

  def self.inherited(klass)
    superclass.inherited(klass)
  end
end
