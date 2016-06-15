class ChangeDeviceCreatedAtInDeviceTransactions < ActiveRecord::Migration
  def change
    change_column :device_transactions, :device_created_at, :string
  end
end
