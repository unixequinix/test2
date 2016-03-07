class Jobs::Credential::TicketChecker < Jobs::Credential::Base
  SUBSCRIPTIONS = %w( ticket_checkin )

  def perform(atts)
    # TODO: Get company_ticket_type from TicketDecoder::SonarDecoder and/or ticket_id

    ActiveRecord::Base.transaction do
      t = CredentialTransaction.find(atts[:transaction_id])
      profile = assign_profile(t, atts)
      ticket = assign_ticket(t, atts)
      assign_ticket_credential(ticket, profile)
      gtag = assign_gtag(t, atts)
      assign_gtag_credential(gtag, profile)
      mark_redeemed(ticket)
    end
  end
end
