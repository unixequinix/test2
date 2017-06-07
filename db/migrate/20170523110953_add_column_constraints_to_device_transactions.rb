class AddColumnConstraintsToDeviceTransactions < ActiveRecord::Migration[5.1]
  def change
    change_column_default :device_transactions, :number_of_transactions, 0
    change_column_null :device_transactions, :number_of_transactions, false
    change_column_null :device_transactions, :server_transactions, false
    DeviceTransaction.where(number_of_transactions: nil).update_all(number_of_transactions: 0)
    DeviceTransaction.where(server_transactions: nil).update_all(server_transactions: 0)
  end
end
