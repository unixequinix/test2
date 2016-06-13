class Operations::Credential::TicketChecker < Operations::Credential::Base
  TRIGGERS = %w( ticket_checkin ).freeze

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    ticket = assign_ticket(t, atts)
    assign_ticket_credential(ticket, atts[:profile_id])
    gtag = Gtag.find_by!(tag_uid: atts[:customer_tag_uid])
    assign_gtag_credential(gtag, atts[:profile_id])
    mark_redeemed(ticket)
  end
end
