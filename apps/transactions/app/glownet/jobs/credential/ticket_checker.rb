class Jobs::Credential::TicketChecker < Jobs::Base
  TYPES = %w( ticket_checkin )

  def perform(transaction_id, atts = {})
    ActiveRecord::Base.transaction do
      t = CredentialTransaction.find(transaction_id)
      # TODO: find or create ticket
      # TODO: assign company ticket type
      # TODO: find or create ticket credential assignment
      t.ticket.update!(credential_redeemed: true)
      profile = t.create_customer_event_profile!(event: t.event)
      tag = t.event.gtags.create!(tag_uid: t.customer_tag_uid)
      tag.credential_assignments.create!(customer_event_profile: profile)
    end

    Jobs::Credential::OrderCreator.perform_later(transaction_id, atts)
  end
end
