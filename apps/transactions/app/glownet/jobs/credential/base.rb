class Jobs::Credential::Base < Jobs::Base
  def assign_profile(transaction, atts)
    transaction.customer_event_profile ||
      transaction.create_customer_event_profile!(event_id: atts[:event_id])
  end

  def assign_gtag(transaction, atts)
    gtags = transaction.event.gtags
    ctt = transaction.ticket.company_ticket_type
    search_atts = { tag_uid: atts[:customer_tag_uid], company_ticket_type: ctt }
    gtags.find_by_tag_uid(atts[:customer_tag_uid]) || gtags.create!(atts)
  end

  def assign_gtag_credential(gtag, profile)
    return if gtag.assigned_gtag_credential
    gtag.create_assigned_gtag_credential!(customer_event_profile: profile)
  end

  def assign_ticket(transaction, atts)
    code = atts[:ticket_code]

    # If ticket is found by code, it is already there, return it.
    ticket_found = transaction.event.includes(:tickets).find_by(tickets: { code: code })
    return ticket_found unless ticket_found.nil?

    # Ticket is not found. perhaps is new sonar ticket?
    ctt = TicketDecoder::SonarDecoder.perform(code)
    return transaction.event.tickets.create!(code: code, company_ticket_type_id: ctt) if ctt

    # it is not sonar, it is not in DB. The ticket is not valid.
    fail "Ticket with code #{code} not found and not sonar."
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
