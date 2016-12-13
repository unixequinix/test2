class AddStatusToDeviceTransactions < ActiveRecord::Migration
  def change
    add_column :device_transactions, :status_code, :integer, default: 0
    add_column :device_transactions, :status_message, :string

    DeviceTransaction.update_all(status_code: 0, status_message: "OK")
  end
end
