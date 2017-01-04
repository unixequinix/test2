class Transactions::Credential::TicketChecker < Transactions::Credential::Base
  TRIGGERS = %w(ticket_checkin).freeze

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    ticket = assign_ticket(t, atts)
    mark_redeemed(ticket)
    return unless atts[:customer_id]
    Gtag.find(atts[:gtag_id]).update!(customer_id: atts[:customer_id])
  end
end
