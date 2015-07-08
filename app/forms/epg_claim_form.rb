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

  validates_presence_of :country_code
  validates_presence_of :state
  validates_presence_of :city
  validates_presence_of :post_code
  validates_presence_of :phone
  validates_presence_of :address
  validates_presence_of :claim_id

  validates_plausible_phone :phone, normalized_country_code: :country_code


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
    self.phone = self.phone.phony_normalized(country_code: self.country_code)
    Parameter.where(category: 'claim', group: 'epg').each do |parameter|
      ClaimParameter.create!(value: attributes[parameter.name.to_sym], claim_id: claim_id, parameter_id: parameter.id)
    end
  end

end