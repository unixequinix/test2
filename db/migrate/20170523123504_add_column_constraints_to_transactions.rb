class AddColumnConstraintsToTransactions < ActiveRecord::Migration[5.1]
  def change
    Transaction.where(action: nil).delete_all
    change_column_null :transactions, :event_id, false
    change_column_null :transactions, :action, false
    change_column_null :transactions, :transaction_origin, false
    change_column_null :transactions, :type, false
    change_column_null :transactions, :device_created_at, false
    change_column_null :transactions, :status_code, false
    change_column_default :transactions, :status_code, 0
  end
end
