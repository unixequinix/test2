class Transactions::Credential::TicketChecker < Transactions::Base
  TRIGGERS = %w[ticket_checkin].freeze

  queue_as :low

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    code = t.ticket_code
    ticket = t.event.tickets.find_by(code: code) || decode_ticket(code, t.event)
    t.update!(ticket: ticket)

    Alert.propagate(t.event, "has been redeemed twice", :high, ticket) && return if ticket.redeemed?

    ticket.update!(redeemed: true)
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
