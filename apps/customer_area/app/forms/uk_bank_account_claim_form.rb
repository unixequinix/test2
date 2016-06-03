class UkBankAccountClaimForm < BankAccountClaimForm
  attribute :bank_name, String
  attribute :sort_code, String
  attribute :account_number, String

  validates_presence_of :bank_name
  validates_presence_of :sort_code
  validates_presence_of :account_number
  validate :sort_code_length?
  validate :account_number_length?

  private

  def sort_code_length?
    return if sort_code.gsub(/[\s-]/, "").strip.length == 6
    errors[:sort_code] << I18n.t("errors.messages.wrong_length", count: 6)
  end

  def account_number_length?
    return if account_number.gsub(/[\s-]/, "").strip.length == 8
    errors[:account_number] << I18n.t("errors.messages.wrong_length", count: 8)
  end
end
