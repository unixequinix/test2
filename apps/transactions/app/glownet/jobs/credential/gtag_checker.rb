class Jobs::Credential::GtagChecker < Jobs::Credential::Base
  TYPES = %w( gtag_checkin )

  def perform(atts)
    ActiveRecord::Base.transaction do
      transaction = CredentialTransaction.find(atts[:transaction_id])
      profile = assign_profile(transaction, atts)
      gtag = assign_gtag(transaction, atts)
      assign_gtag_credential(gtag, profile)
      gtag.update!(credential_redeemed: true)
    end
  end
end
