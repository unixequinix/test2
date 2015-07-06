class EgpClaimForm < Reform::Form

  property :state, virtual: true
  property :city, virtual: true
  property :post_code, virtual: true
  property :telephone, virtual: true
  property :address, virtual: true

  validates_presence_of :state
  validates_presence_of :city
  validates_presence_of :post_code
  validates_presence_of :telephone
  validates_presence_of :address

  def initialize
    super(nil)
  end

  def self.property(name, options={})
    super(name, options.merge(virtual: true)) # every property needs to be virtual.
  end

end