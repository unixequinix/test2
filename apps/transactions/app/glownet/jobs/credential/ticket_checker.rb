class Jobs::Credential::TicketChecker < Jobs::Credential::Base
  TRIGGERS = %w( ticket_checkin )

  def perform(atts)
    ActiveRecord::Base.transaction do
      t = CredentialTransaction.find(atts[:transaction_id])
      profile = t.customer_event_profile
      ticket = assign_ticket(t, atts)
      assign_ticket_credential(ticket, profile)
      gtag = assign_gtag(t, atts)
      assign_gtag_credential(gtag, profile)
      mark_redeemed(ticket)
    end
  end
end
