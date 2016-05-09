class EuroBankAccountClaimForm < BankAccountClaimForm
  attribute :iban, String
  attribute :swift, String

  validates_presence_of :iban
  validates_presence_of :swift
  validates_with SwiftValidator, if: :sepa_validatable?
  validates_with IbanValidator, if: :sepa_validatable?

  def sepa_validatable?
    # TODO: Create boolean casting in Parameter or EventParameter class
    Claim.find(claim_id).profile.event
         .get_parameter("refund", "bank_account", "validate_sepa") == "true"
  end
end
