class AddDeviceCreatedAtFixedToDeviceTransactions < ActiveRecord::Migration
  def change
    add_column :device_transactions, :device_created_at_fixed, :string
  end
end
