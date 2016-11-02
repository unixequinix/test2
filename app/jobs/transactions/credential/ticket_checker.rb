class Transactions::Credential::TicketChecker < Transactions::Credential::Base
  TRIGGERS = %w( ticket_checkin ).freeze

  def perform(atts)
    t = CredentialTransaction.find(atts[:transaction_id])
    ticket = assign_ticket(t, atts)
    assign_profile_to_ticket(ticket, atts[:profile_id])
    gtag = Gtag.find_by!(tag_uid: atts[:customer_tag_uid])
    assign_profile(gtag, atts[:profile_id])
    mark_redeemed(ticket)
  end
end
