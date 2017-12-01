class Transactions::Credential::TicketChecker < Transactions::Base
  TRIGGERS = %w[ticket_checkin].freeze

  queue_as :medium_low

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    ticket = t.ticket
    ticket.redeemed? ? Alert.propagate(t.event, ticket, "has been redeemed twice") : ticket.update!(redeemed: true)
  end
end
