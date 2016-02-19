class Jobs::TicketChecker < ActiveJob::Base
  def perform(transaction_id)
    t = CredentialTransaction.find(transaction_id)
    ActiveRecord::Base.transaction do
      profile = t.create_customer_event_profile!(event: t.event)
      profile.credential_assignments.create!(credentiable: t.ticket)
      tag = t.event.gtags.create!(tag_uid: t.customer_tag_uid)
      tag.credential_assignments.create!(customer_event_profile: profile)
      # TODO: create_customer_order
      # TODO: redeem_customer_order
      t.ticket.update!(credential_redeemed: true)
    end
  end
end
