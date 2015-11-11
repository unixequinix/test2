class EpgClaimForm
  include ActiveModel::Model
  include Virtus.model

  attribute :country_code, String
  attribute :state, String
  attribute :city, String
  attribute :post_code, String
  attribute :phone, String
  attribute :address, String
  attribute :claim_id, Integer
  attribute :agreed_on_claim, Boolean

  validates_presence_of :country_code
  validates_presence_of :state
  validates_presence_of :city
  validates_presence_of :post_code
  validates_presence_of :phone
  validates_presence_of :address
  validates_presence_of :claim_id
  validates_presence_of :agreed_on_claim

  validates_length_of :state, minimum: 1, maximum: 32
  validates_length_of :city, minimum: 1, maximum: 32
  validates_length_of :post_code, minimum: 1, maximum: 10
  validates_length_of :phone, minimum: 1, maximum: 24
  validates_length_of :address, minimum: 5, maximum: 32

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
    #self.phone = self.phone.phony_normalized(country_code: self.country_code)
    Parameter.where(category: 'claim', group: 'epg').each do |parameter|
      cp = ClaimParameter.find_by(claim_id: claim_id, parameter_id: parameter.id)
      cp.nil? ? ClaimParameter.create!(value: attributes[parameter.name.to_sym], claim_id: claim_id, parameter_id: parameter.id) : cp.update(value: attributes[parameter.name.to_sym])
    end
  end

end