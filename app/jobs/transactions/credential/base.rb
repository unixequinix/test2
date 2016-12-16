class Transactions::Credential::Base < Transactions::Base
  def unassign_customer(gtag)
    return unless gtag.customer_id
    gtag.update(active: false, customer: nil)
  end

  def assign_ticket(transaction, atts)
    code = atts[:ticket_code]
    event = transaction.event

    # If ticket is found by code, it is already there, assign and return it.
    ticket = event.tickets.find_by_code(code)
    transaction.update!(ticket: ticket) if ticket
    return ticket if ticket

    # Ticket is not found. perhaps is new sonar ticket?
    decoder = SonarDecoder
    id = decoder.valid_code?(code) && decoder.perform(code)

    # it is not sonar, it is not in DB. The ticket is not valid.
    raise "Ticket with code #{code} not found and not sonar." unless id

    # ticket is sonar. so insert it.
    ctt = event.ticket_types.find_by_company_code(id)
    ticket = event.tickets.create!(code: code, ticket_type: ctt)
    transaction.update!(ticket: ticket)
    ticket
  end

  def mark_redeemed(obj)
    obj.update!(redeemed: true)
  end

  def self.inherited(klass)
    superclass.inherited(klass)
  end
end
