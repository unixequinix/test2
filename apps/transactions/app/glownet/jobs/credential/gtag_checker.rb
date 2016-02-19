class Jobs::Credential::GtagChecker < Jobs::Base
  TYPES = %w( gtag_checkin )

  def perform(transaction_id)
    t = CredentialTransaction.find(transaction_id)

    ActiveRecord::Base.transaction do
      profile = t.customer_event_profile || t.create_customer_event_profile!(event: t.event)
      gtag = t.event.gtags.find_by(tag_uid: t.customer_tag_uid)
      gtag.update!(credential_redeemed: true)
      return if gtag.assigned_gtag_credential
      gtag.create_assigned_gtag_credential!(customer_event_profile: profile)
    end

    Jobs::Credential::OrderCreator.perform_later(transaction_id)
  end
end
