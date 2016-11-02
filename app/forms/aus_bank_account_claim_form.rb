class AusBankAccountClaimForm < BankAccountClaimForm
  attribute :bsb, String
  attribute :number, String
  attribute :bank_name, String
  attribute :account_holder, String

  validates :bsb, presence: true
  validates :number, presence: true
  validates :bank_name, presence: true
  validates :account_holder, presence: true
end
