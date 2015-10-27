class BankAccountClaimForm
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
  validates_with SwiftValidator, message: "Error swift"
  validates_with IbanValidator, message: "Error iban"

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    Parameter.where(category: 'claim', group: 'bank_account').each do |parameter|
      ClaimParameter.create!(value: attributes[parameter.name.to_sym], claim_id: claim_id, parameter_id: parameter.id)
    end
  end

end