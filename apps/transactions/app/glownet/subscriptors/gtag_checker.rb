class GtagChecker

  def perform
    ActiveRecord.transaction do
      profile = customer_event_profile.create!(event: event)
      profile.credential_assignments.create!(credentiable: ticket, event: event)
      # TODO: create_customer_order
      # TODO: redeem_customer_order
      gtag.update!(credential_redeemed: true)
    end
  end
end