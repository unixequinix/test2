class NzBankAccountClaimForm < BankAccountClaimForm

  attribute :number, String
  attribute :account_holder, String

  validates_presence_of :number
  validates_presence_of :account_holder
  validates_with NzValidator

end
