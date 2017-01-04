class Transactions::Credential::TicketValidator < Transactions::Credential::Base
  TRIGGERS = %w(ticket_validation).freeze

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    ticket = assign_ticket(t, atts)
    ticket.update!(redeemed: true)
  end
end
