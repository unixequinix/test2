class EpgClaimForm
  include ActiveModel::Model

  attr_accessor :state, :city, :post_code, :telephone, :address, :customer_id, :claim_id

  validates_presence_of :state
  validates_presence_of :city
  validates_presence_of :post_code
  validates_presence_of :telephone
  validates_presence_of :address

  def initialize(customer, attributes={})
    super()
    @claim = Claim.new
    @claim.generate_claim_number!
    @claim.customer = customer
    @claim.total = customer.assigned_gtag_registration.gtag.gtag_credit_log.amount
    @claim.save!
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def claim
    @claim
  end

  private

  def persist!
    Parameter.where(category: 'claim', group: 'epg').each do |parameter|
      ClaimParameter.create!(value: params[parameter.name], claim_id: @claim.id, parameter_id: parameter.id)
    end
    @claim.start_claim!
  end

end