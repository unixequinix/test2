class BankAccountClaimForm < Reform::Form

  property :iban, virtual: true
  property :swift, virtual: true

  validates_presence_of :iban
  validates_presence_of :swift

  def initialize
    super(nil)
  end

  def self.property(name, options={})
    super(name, options.merge(virtual: true)) # every property needs to be virtual.
  end

end