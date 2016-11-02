class BankAccountClaimForm
  include ActiveModel::Model
  include Virtus.model

  attribute :claim_id, Integer
  attribute :agreed_on_claim, Boolean

  validates :claim_id, presence: true
  validates :agreed_on_claim, presence: true

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
      parameter = Parameter.find_by(category: "claim", group: "bank_account", name: attribute.to_s)
      ClaimParameter.create!(
        value: attributes[parameter.name.to_sym],
        claim_id: claim_id, parameter_id: parameter.id
      )
    end
  end
end
