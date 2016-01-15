class EuroBankAccountClaimForm
  include ActiveModel::Model
  include Virtus.model

  attribute :iban, String
  attribute :swift, String
  attribute :claim_id, Integer
  attribute :agreed_on_claim, Boolean

  validates_presence_of :iban
  validates_presence_of :swift
  validates_presence_of :claim_id
  validates_presence_of :agreed_on_claim
  validates_with SwiftValidator, if: :sepa_validatable?
  validates_with IbanValidator, if: :sepa_validatable?

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def form_attributes
    attributes = self.attributes.keys
    attributes.delete(:claim_id)
    attributes.delete(:agreed_on_claim)
    attributes
  end

  private

  def persist!
    form_attributes.each do |attribute|
      parameter = Parameter.find_by(category: 'claim', group: 'bank_account', name: attribute.to_s)
      ClaimParameter.create!(
        value: attributes[parameter.name.to_sym],
        claim_id: claim_id, parameter_id: parameter.id)
    end
  end

  def sepa_validatable?
    # TODO: Create boolean casting in Parameter or EventParameter class
    Claim.find(claim_id).customer_event_profile.event.get_parameter('refund', 'bank_account', 'validate_sepa') == 'true'
  end
end
