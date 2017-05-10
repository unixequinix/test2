class AddDeviceIdToDeviceTransactions < ActiveRecord::Migration[5.0]
  def change
    add_reference :device_transactions, :device, foreign_key: true, index: true
  end
end
