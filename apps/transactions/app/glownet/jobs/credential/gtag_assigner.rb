class Jobs::Credential::GtagAssigner < Jobs::Credential::Base
  TYPES = %w( gtag_assignment gtag_unassignment ticket_assignment ticket_unassignment )

  def perform(atts)
    ActiveRecord::Base.transaction do
      transaction = CredentialTransaction.find(atts[:transaction_id])
      profile = assign_profile(transaction, atts)
      gtag = assign_gtag(transaction, atts)
      assign_gtag_credential(gtag, profile)
      # TODO: Create customer and/or online order
    end
  end
end
