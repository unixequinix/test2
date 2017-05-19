class AddServerTransactionsToDeviceTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :device_transactions, :server_transactions, :integer, dfault: 0
    DeviceTransaction.update_all(server_transactions: 0)

  end
end
