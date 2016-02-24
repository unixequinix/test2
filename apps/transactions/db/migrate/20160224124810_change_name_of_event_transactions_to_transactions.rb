class ChangeNameOfEventTransactionsToTransactions < ActiveRecord::Migration
  def change
    rename_table :event_transactions, :transactions
  end
end
