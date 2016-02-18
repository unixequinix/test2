class Accreditator < ActiveJob::Base
  def perform(transaction_id)
    t = CredentialTransaction.find(transaction_id)

    ActiveRecord.transaction do
      gtag = Gtag.find_by(event: t.event, tag_uid: t.customer_tag_uid)
      profile = t.customer_event_profile.create!(event: t.event)
      gtag.credential_assignments.create!(customer_event_profile: profile)
    end

    OrderRedemptor.perform_later(transaction_id)
  end
end
