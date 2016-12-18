class Transactions::Credential::TicketChecker < Transactions::Credential::Base
  TRIGGERS = %w( ticket_checkin ).freeze

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    ticket = assign_ticket(t, atts)
    mark_redeemed(ticket)
    if atts[:customer_id]
      gtag = Gtag.find_by(event_id: atts[:event_id], tag_uid: atts[:customer_tag_uid])
      gtag.update!(customer_id: atts[:customer_id])
    end
  end
end
