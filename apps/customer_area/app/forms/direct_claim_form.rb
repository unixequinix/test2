class DirectClaimForm
  include ActiveModel::Model
  include Virtus.model

  attribute :claim_id, Integer
  attribute :agreed_on_claim, Boolean

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
    attributes.delete(:claim_id)
    attributes.delete(:agreed_on_claim)
    attributes
  end

  private

  def persist!
    form_attributes.each do |attribute|
      parameter = Parameter.find_by(category: "claim", group: "direct", name: attribute.to_s)
      ClaimParameter.create!(
        value: attributes[parameter.name.to_sym],
        claim_id: claim_id, parameter_id: parameter.id)
    end
  end
end
