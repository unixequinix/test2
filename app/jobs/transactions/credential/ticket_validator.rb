class Transactions::Credential::TicketValidator < Transactions::Credential::Base
  TRIGGERS = %w(ticket_validation).freeze

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    ticket = assign_ticket(t, atts)
    mark_redeemed(ticket)
  end
end
