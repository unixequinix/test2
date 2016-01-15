class AusBankAccountClaimForm
  include ActiveModel::Model
  include Virtus.model

  attribute :bsb, String
  attribute :number, String
  attribute :bank_name, String
  attribute :account_holder, String
  attribute :claim_id, Integer
  attribute :agreed_on_claim, Boolean

  validates_presence_of :bsb
  validates_presence_of :number
  validates_presence_of :bank_name
  validates_presence_of :account_holder
  validates_presence_of :claim_id
  validates_presence_of :agreed_on_claim

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
end
