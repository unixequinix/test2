class Jobs::Credential::Assigner < Jobs::Credential::Base
  TYPES = %w( gtag_assignment ticket_assignment )

  def perform(atts)
    _identifier = atts[:customer_tag_uid] || atts[:ticket_id]

    ActiveRecord::Base.transaction do
      transaction = CredentialTransaction.find(atts[:transaction_id])
      profile = assign_profile(transaction, atts)
      gtag = assign_gtag(transaction, atts)
      assign_gtag_credential(gtag, profile)
      # TODO: Create customer and/or online order
    end
  end
end
