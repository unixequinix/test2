class Jobs::Credential::TicketChecker < Jobs::Credential::Base
  TYPES = %w( ticket_checkin )

  def perform(atts)
    atts = pre_process(atts)
    ActiveRecord::Base.transaction do
      t = CredentialTransaction.find(atts[:transaction_id])
      ticket = assign_ticket(t, atts)
      profile = assign_profile(t, atts)
      tag = assign_gtag(t, atts)
      assign_gtag_credential(tag, profile)
      assign_ticket_credential(ticket, profile)
      t.ticket.update!(credential_redeemed: true)
    end

    Jobs::Credential::OrderCreator.perform_later(transaction_id, atts)
  end

  private

  def pre_process(atts)
    # TODO: assign company ticket type for non sonar
    atts[:company_ticket_type_id] = 1
    atts
  end
end
