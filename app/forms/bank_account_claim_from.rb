class BankAccountClaimForm
  include ActiveModel::Model
  include Virtus.model

  attribute :iban, String
  attribute :swift, String

  validates_presence_of :iban
  validates_presence_of :swift

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