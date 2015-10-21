class ChangeNumberInBankAccounts < ActiveRecord::Migration
  def change
    rename_column :bank_accounts, :number, :iban
  end
end
