class Transactions::Credential::TicketChecker < Transactions::Base
  TRIGGERS = %w[ticket_checkin ticket_validation].freeze

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    ticket = assign_ticket(t, atts)
    ticket.update!(redeemed: true)
    return unless atts[:customer_id] && atts[:gtag_id]
    Gtag.find(atts[:gtag_id]).update!(customer_id: atts[:customer_id])
  end

  def assign_ticket(transaction, atts) # rubocop:disable Metrics/MethodLength
    code = atts[:ticket_code]
    event = transaction.event

    # If ticket is found by code, it is already there, assign and return it.
    ticket = event.tickets.find_by(code: code)
    transaction.update!(ticket: ticket) if ticket
    return ticket if ticket

    # Ticket is not found. perhaps is new sonar ticket?
    decoder = SonarDecoder
    id = decoder.valid_code?(code) && decoder.perform(code)

    # it is not sonar, it is not in DB. The ticket is not valid.
    raise "Ticket with code #{code} not found and not sonar." unless id

    # ticket is sonar. so insert it.
    ctt = event.ticket_types.find_by(company_code: id)
    begin
      ticket = event.tickets.find_or_create_by!(code: code, ticket_type: ctt)
      transaction.update!(ticket: ticket)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    ticket
  end
end
