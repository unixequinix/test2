class NzValidator < ActiveModel::Validator
  def validate(record)
    bank_account = record.number.gsub(/[\s-]/, "").strip
    bank_id = bank_account[0..1]
    branch_id = bank_account[2..5]
    account_number = bank_account[6..12]
    suffix = bank_account[13..15]
    unless (bank_account.length == 15 || bank_account.length == 16) &&
      ValidateNzBankAcc.new(bank_id, branch_id, account_number, suffix).valid?
      record.errors.add :number, record.errors.generate_message(:number, :invalid)
    end
  end
end