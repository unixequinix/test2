class EpgClaimForm
  include ActiveModel::Model

  attr_accessor(
    :state,
    :city,
    :post_code,
    :telephone,
    :address,
  )

  validates_presence_of :state
  validates_presence_of :city
  validates_presence_of :post_code
  validates_presence_of :telephone
  validates_presence_of :address

  def initialize(customer)
    @customer = customer
    @claim = Claim.new
    @claim.generate_claim_number!
    @claim.start_claim!
    @claim.customer = @customer
    @claim.total = @customer.assigned_gtag_registration.gtag.gtag_credit_log.amount
  end

  def submit(params)
    if persist(params)
      true
    else
      false
    end
  end

  def claim
    @claim
  end

  private

  def persist(params)

    if @claim.save
      Parameter.where(category: 'claim', group: 'epg').each do |parameter|
        ClaimParameter.create(value: params[parameter.name], claim_id: @claim.id, parameter_id: parameter.id)
      end
      true
    else
      false
    end
  end

end