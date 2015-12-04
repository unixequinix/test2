class AddSwiftToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :swift, :string
  end
end
