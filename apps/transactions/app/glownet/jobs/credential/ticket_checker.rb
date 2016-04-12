class Jobs::Credential::TicketChecker < Jobs::Credential::Base
  TRIGGERS = %w( ticket_checkin )

  def perform(atts)
    ActiveRecord::Base.transaction do
      t = CredentialTransaction.find(atts[:transaction_id])
      ticket = assign_ticket(t, atts)
      assign_ticket_credential(ticket, atts[:customer_event_profile_id])
      gtag = assign_gtag(t, atts)
      assign_gtag_credential(gtag, atts[:customer_event_profile_id])
      mark_redeemed(ticket)
    end
  end
end
