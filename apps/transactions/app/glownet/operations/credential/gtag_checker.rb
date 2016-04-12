class Operations::Credential::GtagChecker < Operations::Credential::Base
  TRIGGERS = %w( gtag_checkin )

  def perform(atts)
    ActiveRecord::Base.transaction do
      transaction = CredentialTransaction.find(atts[:transaction_id])
      gtag = assign_gtag(transaction, atts)
      assign_gtag_credential(gtag, atts[:customer_event_profile_id])
      mark_redeemed(gtag)
    end
  end
end
