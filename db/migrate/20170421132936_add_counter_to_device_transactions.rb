class AddCounterToDeviceTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :device_transactions, :counter, :integer, default: 0, null: false
  end
end
