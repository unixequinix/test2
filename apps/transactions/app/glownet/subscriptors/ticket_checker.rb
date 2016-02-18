class TicketChecker

  def perform
    ActiveRecord.transaction do
      profile = customer_event_profile.create!(event: event)
      profile.credential_assignments.create!(credentiable: ticket, event: event)
      tag = event.gtags.create!(tag_uid: customer_tag_uid)
      tag.credential_assignments.create!(event: event, customer_event_profile: profile)
      # TODO: create_customer_order
      # TODO: redeem_customer_order
      ticket.update!(credential_redeemed: true)
    end
  end
end