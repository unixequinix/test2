class ChangeDeviceUidInTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :device_id, :integer
    add_index :transactions, :device_id
  end
end
