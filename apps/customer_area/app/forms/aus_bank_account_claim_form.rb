class AusBankAccountClaimForm < BankAccountClaimForm
  attribute :bsb, String
  attribute :number, String
  attribute :account_holder, String

  validates_presence_of :bsb
  validates_presence_of :number
  validates_presence_of :account_holder
end
