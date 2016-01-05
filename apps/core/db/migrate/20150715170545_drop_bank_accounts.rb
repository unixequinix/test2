class DropBankAccounts < ActiveRecord::Migration
  def change
    drop_table :bank_accounts
  end
end
