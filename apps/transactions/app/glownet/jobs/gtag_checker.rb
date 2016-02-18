class GtagChecker < ActiveJob::Base
  def perform(transaction_id)
    t = CredentialTransaction.find(transaction_id)

    ActiveRecord.transaction do
      profile = t.customer_event_profile.create!(event: t.event)
      profile.credential_assignments.create!(credentiable: t.ticket)
      gtag.update!(credential_redeemed: true)
    end

    OrderRedemptor.perform_later(transaction_id)
  end
end
