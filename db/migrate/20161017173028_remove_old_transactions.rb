class RemoveOldTransactions < ActiveRecord::Migration
  def change
    drop_table :credit_transactions
    drop_table :money_transactions
    drop_table :access_transactions
    drop_table :credential_transactions
    drop_table :ban_transactions
    drop_table :device_transactions
    drop_table :order_transactions

    remove_column :transactions, :old_id
  end
end
