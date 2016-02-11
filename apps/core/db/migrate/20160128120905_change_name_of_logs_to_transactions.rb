class ChangeNameOfLogsToTransactions < ActiveRecord::Migration
  def change
    rename_table :event_logs, :event_transactions
  end
end
