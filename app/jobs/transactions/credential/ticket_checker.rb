class Transactions::Credential::TicketChecker < Transactions::Base
  TRIGGERS = %w[ticket_checkin ticket_validation].freeze

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    ticket = assign_ticket(t)
    ticket.redeemed? ? Alert.propagate(t.event, "has been redeemed twice", :high, ticket) : ticket.update!(redeemed: true)
  end

  def assign_ticket(transaction)
    code = transaction.ticket_code
    event = transaction.event
    ticket = event.tickets.find_by(code: code) || decode_ticket(code, event)
    gtag = transaction.gtag

    if ticket.customer_not_anonymous?
      old_customer = gtag.customer
      gtag.update!(customer: ticket.customer)
      transaction.update!(customer: ticket.customer)
      old_customer.destroy if old_customer.reload.credentials.empty?
    else
      ticket.customer&.destroy
      ticket.update!(customer: gtag.customer)
    end

    transaction.update!(ticket: ticket)
    ticket
  end

  def decode_ticket(code, event)
    # Ticket is not found. perhaps is new sonar ticket?
    id = SonarDecoder.valid_code?(code) && SonarDecoder.perform(code)

    # it is not sonar, it is not in DB. The ticket is not valid.
    raise "Ticket with code #{code} not found and not sonar." unless id

    # ticket is sonar. so insert it.
    ctt = event.ticket_types.find_by(company_code: id)
    begin
      ticket = event.tickets.find_or_create_by!(code: code, ticket_type: ctt)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    ticket
  end
end
