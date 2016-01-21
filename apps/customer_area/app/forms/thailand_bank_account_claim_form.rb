class ThailandBankAccountClaimForm < BankAccountClaimForm

  attribute :account_holder, String
  attribute :account_holder_translation, String
  attribute :bank_name, String
  attribute :number, String

  validates_presence_of :account_holder
  validates_presence_of :account_holder_translation
  validates_presence_of :number
  validates_presence_of :bank_name

end
