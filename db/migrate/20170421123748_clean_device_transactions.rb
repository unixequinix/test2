class CleanDeviceTransactions < ActiveRecord::Migration[5.0]
  def change
    remove_column :device_transactions, :device_db_index, :integer
    remove_column :device_transactions, :status_code, :integer
    remove_column :device_transactions, :device_created_at, :datetime
    remove_column :device_transactions, :device_created_at_fixed, :string
    remove_column :device_transactions, :status_message, :string

    add_column :device_transactions, :battery, :integer
  end
end
